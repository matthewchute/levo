//
//  ResultsViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-07-12.
//

import UIKit
import CoreBluetooth

class BLEViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    var xAcc: [Float] = []
    var yAcc: [Float] = []
    var zAcc: [Float] = []
    var agl2gndX: [Float] = []
    var agl2gndY: [Float] = []
    var agl2gndZ: [Float] = []
    var packetNum: [Int] = []
    var counter: Int = 0
    var done_flag: Bool = false
    var sample_period: Float = 0.0
    var xGyro: [Float] = []
    var yGyro: [Float] = []
    var zGyro: [Float] = []
    
    @IBOutlet weak var data_label: UILabel!
    @IBOutlet weak var back_btn: UIButton!
    
    @IBAction func didTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        back_btn.setTitle("Cancel Set", for: .normal)
        back_btn.layer.cornerRadius = 20
    }
    
    // parse str sent over ble and collect x y z accelerations and store them in respective array
    func parseString(str: String) -> Void {
        let stringArr: [String] = str.components(separatedBy: ",")
        if stringArr[0] == "EOF" {
            sample_period = Float(stringArr[1]) ?? 0.0
            print("Complete")
            done_flag = true
        } else {
            // append xyz acceleration values
            xAcc.append(Float(stringArr[0]) ?? 0.0)
            yAcc.append(Float(stringArr[1]) ?? 0.0)
            zAcc.append(Float(stringArr[2]) ?? 0.0)
            xGyro.append(Float(stringArr[3]) ?? 7.0)
            yGyro.append(Float(stringArr[4]) ?? 7.0)
            zGyro.append(Float(stringArr[5]) ?? 7.0)
            agl2gndX.append(Float(stringArr[6]) ?? 0.0)
            agl2gndY.append(Float(stringArr[7]) ?? 0.0)
            agl2gndZ.append(Float(stringArr[8]) ?? 0.0)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            data_label.text = "Connecting to Levo..."
            print("BLE is powered on")
        } else {
            data_label.text = "BLE Error"
            print("BLE IS BROKEN")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let pname = peripheral.name {
            if pname == "esp32" || pname == "ESP32" {
                self.centralManager.stopScan()
                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                self.centralManager.connect(peripheral, options: nil)
                data_label.text = "Levo Connected."
                print("ESP32 is connected")
                // This is for debugging purpose. Will remove after completion - Antonio
                //print("Peripheral Discovered: \(peripheral)")
                //print("Peripheral name: \(peripheral.name)")
                //print ("Advertisement Data : \(advertisementData)")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.myPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("********************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        BlePeripheral.connectedService = services[0]
        print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
        guard let characteristics = service.characteristics else {
          return
        }

        print("Found \(characteristics.count) characteristics.")

        for characteristic in characteristics {
            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                BlePeripheral.connectedRXChar = rxCharacteristic
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
                print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                BlePeripheral.connectedTXChar = txCharacteristic
                print("TX Characteristic: \(txCharacteristic.uuid)")
            }
        }
        BlePeripheral.connectedPeripheral = myPeripheral
        writeOutgoingValue()
        
        sleep(1)
    }
    
    func writeOutgoingValue(){
        let valueString = ("start" as NSString).data(using: String.Encoding.utf8.rawValue)
          //change the "data" to valueString
        if let blePeripheral = myPeripheral {
            if let txCharacteristic = BlePeripheral.connectedTXChar {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                print("***start****")
                data_label.text = "Begin Exercise."
            }
        }
    }
}

extension BLEViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("*****************************************")
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Is Powered On.")
        case .unsupported:
            print("Peripheral Is Unsupported.")
        case .unauthorized:
            print("Peripheral Is Unauthorized.")
        case .unknown:
            print("Peripheral Unknown")
        case .resetting:
            print("Peripheral Resetting")
        case .poweredOff:
            print("Peripheral Is Powered Off.")
        @unknown default:
            print("Error")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        var characteristicASCIIValue = NSString()

        guard characteristic == rxCharacteristic,

        let characteristicValue = characteristic.value,
        let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }

        characteristicASCIIValue = ASCIIstring
        
        parseString(str: characteristicASCIIValue as String)

        if !done_flag {
            //print("\(xGyro[counter]) \(xGyro[counter+1]) \n \(yGyro[counter]) \(yGyro[counter+1]) \n \(zGyro[counter]) \(zGyro[counter+1])")
            data_label.text = "Processing Data...\n Please wait."
            counter += 2
        } else {
            centralManager.cancelPeripheralConnection(myPeripheral)
            let xdata: [Float] = xAcc
            let ydata: [Float] = yAcc
            let zdata: [Float] = zAcc
            let xagl: [Float] = agl2gndX
            let yagl: [Float] = agl2gndY
            let zagl: [Float] = agl2gndZ
            let sp: Float = sample_period
            let xgyro: [Float] = xGyro
            let ygyro: [Float] = yGyro
            let zgyro: [Float] = zGyro
            NotificationCenter.default.post(name: Notification.Name("data"), object: (xdata, ydata, zdata, xagl, yagl, zagl, sp, xgyro, ygyro, zgyro))
            dismiss(animated: true, completion: nil)
        }
    }
}
