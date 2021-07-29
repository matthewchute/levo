from micropython import const
import struct
import bluetooth
import time
import machine
import utime
import ujson, math


_ADV_TYPE_FLAGS = const(0x01)
_ADV_TYPE_NAME = const(0x09)
_ADV_TYPE_UUID16_COMPLETE = const(0x3)
_ADV_TYPE_UUID32_COMPLETE = const(0x5)
_ADV_TYPE_UUID128_COMPLETE = const(0x7)
_ADV_TYPE_UUID16_MORE = const(0x2)
_ADV_TYPE_UUID32_MORE = const(0x4)
_ADV_TYPE_UUID128_MORE = const(0x6)
_ADV_TYPE_APPEARANCE = const(0x19)

_IRQ_CENTRAL_CONNECT = const(1)
_IRQ_CENTRAL_DISCONNECT = const(2)
_IRQ_GATTS_WRITE = const(3)

_FLAG_WRITE = const(0x0008)
_FLAG_NOTIFY = const(0x0010)

_UART_UUID = bluetooth.UUID("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
_UART_TX = (
    bluetooth.UUID("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"),
    _FLAG_NOTIFY,
)
_UART_RX = (
    bluetooth.UUID("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"),
    _FLAG_WRITE,
)
_UART_SERVICE = (
    _UART_UUID,
    (_UART_TX, _UART_RX),
)

_ADV_APPEARANCE_GENERIC_COMPUTER = const(128)

# Bluetooth Declarations 

#globals
noiseX = 0.1
noiseY = 0.1
noiseZ = 0.1
ngyroX = 0
ngyroY = 0
ngyroZ = 0
accScale = 16384.00 # 4g
gyroScale = 16.375
g = 9.81
sample_period = 0
EOF_STR1 = 'EOF,'
EOF_STR2 = 'EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,EOF,'


def initDevice():
    i2c = machine.SoftI2C(scl = machine.Pin(19), sda = machine.Pin(18))
    deviceaddr = i2c.scan()
    i2c.writeto_mem(deviceaddr[0], 16, b'\xF0')
    i2c.writeto_mem(deviceaddr[0], 17, b'\x4c')
    return deviceaddr[0], i2c

def readAcc(deviceaddr,i2c):
    xlwr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 40, 1), "big")
    xupr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 41, 1), "big")
    xg = ((xupr<<8)|xlwr)#/accScale)
    ylwr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 42, 1), "big")
    yupr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 43, 1), "big")
    yg = ((yupr<<8)|ylwr)#/accScale)
    zlwr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 44, 1), "big")
    zupr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 45, 1), "big")
    zg = ((zupr<<8)|zlwr)#/accScale)
    
    if(xg > 32768):
        xg = xg - 65536
    if(yg > 32768):
        yg = yg - 65536
    if(zg > 32768):
        zg = zg - 65536
    
    xg = xg/accScale
    yg = yg/accScale
    zg = zg/accScale
    
    
    return xg, yg, zg
    
def readGy(deviceaddr,i2c):
    xlwr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 34, 1), "big")
    xupr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 35, 1), "big")
    xgy = ((xupr<<8)|xlwr)#/accScale)
    ylwr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 36, 1), "big")
    yupr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 37, 1), "big")
    ygy = ((yupr<<8)|ylwr)#/accScale)
    zlwr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 38, 1), "big")
    zupr = int.from_bytes(i2c.readfrom_mem(deviceaddr, 39, 1), "big")
    zgy = ((zupr<<8)|zlwr)#/accScale)
    
    if(xgy > 32768):
        xgy = xgy - 65536
    if(ygy > 32768):
        ygy = ygy - 65536
    if(zgy > 32768):
        zgy = zgy - 65536
    
    xgy = xgy/gyroScale
    ygy = ygy/gyroScale
    zgy = zgy/gyroScale
    
    return xgy, ygy, zgy
    
### rest checks
def is_accelerating(Ax_inst,Ay_inst,Az_inst, magList):
    movementFlag=0 #tells if bar is in movement or at rest (0 = no accelleration, 1 = accelerating)
    mag = math.sqrt((Ax_inst)**2+(Ay_inst)**2+(Az_inst)**2) #check magnitude of sensor readings
    for i in range(len(magList)-1):
        magList[i] = magList[i+1]
    magList[len(magList)-1] = mag
    #mags.append(mag)
    if min(magList) > 0.95 and max(magList) < 1.05: #if the lowest and highest values for accelerations 
        movementFlag = 0 #in movement buffer are g +/- 5%, bar is not accelerating
    else:
        movementFlag = 1 #if the bar has accelerated withing the last 0.145 sec, do not recalulated downward direction   
    return movementFlag, magList #return the movement flag and the buffer.
    
def angle_finder(restReading,lastAngle): 
    if restReading<=1 and restReading>=-1: #make sure the value read is in range for arccos
        agl = math.acos(restReading) #if in range of acos, find the angle
    elif restReading > 1: #if the angle is greater than 1 assume sensor is directly facing the ground
        agl = 0
    elif restReading < -1: #if reading is less than 1 g, assume sensor is oppposite to ground
        agl = math.pi
        
    return agl #return sensor angle to ground 

### BLE
def advertising_payload(limited_disc=False, br_edr=False, name=None, services=None, appearance=0):
    payload = bytearray()

    def _append(adv_type, value):
        nonlocal payload
        payload += struct.pack("BB", len(value) + 1, adv_type) + value

    _append(
        _ADV_TYPE_FLAGS,
        struct.pack("B", (0x01 if limited_disc else 0x02) + (0x18 if br_edr else 0x04)),
    )

    if name:
        _append(_ADV_TYPE_NAME, name)

    if services:
        for uuid in services:
            b = bytes(uuid)
            if len(b) == 2:
                _append(_ADV_TYPE_UUID16_COMPLETE, b)
            elif len(b) == 4:
                _append(_ADV_TYPE_UUID32_COMPLETE, b)
            elif len(b) == 16:
                _append(_ADV_TYPE_UUID128_COMPLETE, b)
    if appearance:
        _append(_ADV_TYPE_APPEARANCE, struct.pack("<h", appearance))

    return payload

class BLEUART:
    def __init__(self, ble, name="esp32", rxbuf=100):
        self._ble = ble
        self._ble.active(True)
        self._ble.irq(self._irq)
        ((self._tx_handle, self._rx_handle),) = self._ble.gatts_register_services((_UART_SERVICE,))
        # Increase the size of the rx buffer and enable append mode.
        self._ble.gatts_set_buffer(self._rx_handle, rxbuf, True)
        self._connections = set()
        self._rx_buffer = bytearray()
        self._handler = None
        # Optionally add services=[_UART_UUID], but this is likely to make the payload too large.
        self._payload = advertising_payload(name=name, appearance=_ADV_APPEARANCE_GENERIC_COMPUTER)
        self._advertise()

    def irq(self, handler):
        self._handler = handler

    def _irq(self, event, data):
    
        if event == _IRQ_CENTRAL_CONNECT:
            conn_handle, _, _ = data
            self._connections.add(conn_handle)
        elif event == _IRQ_CENTRAL_DISCONNECT:
            conn_handle, _, _ = data
            if conn_handle in self._connections:
                self._connections.remove(conn_handle)
            # Start advertising again to allow a new connection.
            self._advertise()
        elif event == _IRQ_GATTS_WRITE:
            conn_handle, value_handle = data
            if conn_handle in self._connections and value_handle == self._rx_handle:
                self._rx_buffer += self._ble.gatts_read(self._rx_handle)
                if self._handler:
                    self._handler()
            
    def any(self):
        return len(self._rx_buffer)

    def read(self, sz=None):
        if not sz:
            sz = len(self._rx_buffer)
        result = self._rx_buffer[0:sz]
        self._rx_buffer = self._rx_buffer[sz:]
        return result

    def write(self, data):
        for conn_handle in self._connections:
            self._ble.gatts_notify(conn_handle, self._tx_handle, data)

    def close(self):
        for conn_handle in self._connections:
            self._ble.gap_disconnect(conn_handle)
        self._connections.clear()

    def _advertise(self, interval_us=500000):
        self._ble.gap_advertise(interval_us, adv_data=self._payload)

def sendMessages(send_string):
    uart.write(send_string)
    time.sleep_ms(10)
    
def accnoisecalib(deviceaddr,i2c):
    nzx = []
    nzy = []
    nzz = []
    noiseX = 0
    noiseY = 0
    noiseZ = 0
    for i in range(100):
        Nx,Ny,Nz = readGy(deviceaddr,i2c)
        nzx.append(Nx)
        nzy.append(Ny)
        nzz.append(Nz)
    for i in range (100):
        noiseX = noiseX + nzx[i]
        noiseY = noiseY + nzy[i]
        noiseZ = noiseZ + nzz[i]
    print(noiseX/100, '  ', noiseY/100, '  ', noiseZ/100)
    return (noiseX/100) , (noiseY/100), (noiseZ/100)

def data_collect():
    deviceaddr, i2c = initDevice()
    machine.freq(240000000)
    

    open('dat.txt','w').close()
    accX = 0
    aglX = 0
    gyroX = 0
    accY = 0
    aglY = 0
    gyroY = 0
    accZ = 0
    aglZ = 0
    gyroZ = 0
    
    #noiseX,noiseY,noiseZ = accnoisecalib(deviceaddr,i2c)
    
    magsList = [1]*5
    agl2gndX = 0 #assume x is facing ground
    agl2gndY = 0 #assume y, z are parallel to ground
    agl2gndZ = 22/14
    idx = 0
    loop = 500
    datfile = open('dat.txt','a')
    #ble = bluetooth.BLE()
    #uart = BLEUART(ble)
    tick = time.ticks_ms()
    #def on_rx():
    #    if uart.read().decode().strip() == "start":
    #        print_this()
    #    else:
    #        print("Wrong input.")
    
    #uart.irq(handler=on_rx)
    while(idx<=loop):
    
        #Read Accelerometer raw value
    
        Ax, Ay, Az = readAcc(deviceaddr,i2c)
    
        #Read Gyroscope raw value
        gyro_x,gyro_y,gyro_z = readGy(deviceaddr,i2c)

        ## Assess accelleration and angle to ground
        motionFlag, magsList = is_accelerating(Ax,Ay,Az, magsList)
        #THIS IS GOTTA CHANGE FROM THE MPU6050 to the LSM6#############y
        Gx = ((gyro_x) - ngyroX)#*360
        Gy = ((gyro_y) - ngyroY)#*360 #########Gy noise proportional to A in plane
        Gz = ((gyro_z) - ngyroZ)#*360
        if motionFlag < 1:
            agl2gndX = angle_finder((Ax-noiseX),agl2gndX)
            agl2gndY = angle_finder((Ay-noiseY),agl2gndY)
            agl2gndZ = angle_finder((Az-noiseZ),agl2gndZ)
        
        #remove constant noise ##ax ay swapped fpr testing
        Ax = (Ax - noiseX)*g - g*math.cos(agl2gndX) #- noiseX#convert to m/s^2
        Ay = (Ay - noiseY)*g - g*math.cos(agl2gndY) #- noiseY
        Az = (Az - noiseZ)*g - g*math.cos(agl2gndZ) #- noiseZ
        
    
        datstr = str(Ax)+','+str(Ay)+','+str(Az)+','+str(Gx)+','+str(Gy)+','+str(Gz)+','+str(agl2gndX)+','+str(agl2gndY)+','+str(agl2gndZ)+'\n' #Yy for zero
        
        datfile.write(datstr)
        
        
        idx += 1
       
    #END WHILE
     
    tock = time.ticks_ms()
    sample_period = time.ticks_diff(tock,tick)/loop
    print(sample_period)
    datfile.close()
    read_fl = open('dat.txt','r')
    
    # ble = bluetooth.BLE()
    # uart = BLEUART(ble)
    # utime.sleep_ms(500)
    
    for i in range(math.ceil(loop)):
        send_string = ''
        for j in range(1):
            temp = read_fl.readline().strip("\n")
            send_string = send_string + temp + ','
        sendMessages((str(send_string)))# +str(i)))
        #print(send_string)
    EOF_STR = EOF_STR1 + str(sample_period) + ',' + EOF_STR2
    sendMessages(EOF_STR)
     
    uart.close()
    datfile.close()

if __name__ == "__main__":

    ble = bluetooth.BLE()
    uart = BLEUART(ble)
    tick = time.ticks_ms()
    print('pre rx')
    def on_rx():
        if uart.read().decode().strip() == "start":
            data_collect()
        else:
            print("Wrong input.")
    
    uart.irq(handler=on_rx)
    
    
    
