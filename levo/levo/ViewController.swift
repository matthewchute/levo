
//  ViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-06-21.
//
import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    var xAcc: [Float] = []
    var yAcc: [Float] = []
    var zAcc: [Float] = []
    var counter: Int = 0
    var done_flag: Bool = false
    var sample_period: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBOutlet weak var data_label: UILabel!
    
    // parse str sent over ble and collect x y z accelerations and store them in respective array
    func parseString(str: String) -> Void {
        let stringArr: [String] = str.components(separatedBy: ",")
        if stringArr[0] == "EOF" {
            // disconnect peripheral connection
            sample_period = Float(stringArr[1]) ?? 0.0
            centralManager.cancelPeripheralConnection(myPeripheral)
            data_label.text = "Complete."
            done_flag = true
        } else {
            // append xyz acceleration values
            xAcc.append(Float(stringArr[0]) ?? 0.0)
            xAcc.append(Float(stringArr[9]) ?? 0.0)
            yAcc.append(Float(stringArr[1]) ?? 0.0)
            yAcc.append(Float(stringArr[10]) ?? 0.0)
            zAcc.append(Float(stringArr[2]) ?? 0.0)
            zAcc.append(Float(stringArr[11]) ?? 0.0)
        }
    }
    
    func process_data(xData: [Float]) -> Void {
        var velX = trap_rule(data: xData)
    }
    
    // trapezoid rule
    func trap_rule(data: [Float]) -> [Float] {
        var integral: [Float] = []
        var prev:Float = 0.0
        var area:Float = 0.0
        for i in 0...data.count-1 {
            area = (sample_period/2)*(data[i]+data[i+1])
            integral.append(area+prev)
            prev += area
        }
        integral.append(integral[data.count-1])
        return integral
    }
    
    // matrix transpose
    func tpose(_ a: [[Float]]) -> [[Float]] {
        let rows_a = a.count
        let cols_a = a[0].count
        var atrans: [[Float]] = []
        for ca in 0...cols_a {
            var temp_row: [Float] = []
            for ra in 0...rows_a {
                temp_row.append(a[ra][ca])
            }
            atrans.append(temp_row)
        }
        return atrans
    }
    
    // matrix multiply
    func matx(_ a:[[Float]], _ b:[[Float]]) -> [[Float]] {
        var c:[[Float]] = []
        let rows_a = a.count
        let cols_a = a[0].count
        let cols_b = b[0].count
        for ra in 0...rows_a {
            var temp_row: [Float] = []
            for cb in 0...cols_b {
                var temp_ele:Float = 0.0
                for ca in 0...cols_a {
                    temp_ele += a[ra][ca]*b[ca][cb]
                }
                temp_row.append(temp_ele)
            }
            c.append(temp_row)
        }
        return c
    }
    
    // inverse 2d matrix
    func inv2(_ a:[[Float]]) -> [[Float]] {
        var b:[[Float]] = []
        b.append([a[1][1], -1*a[0][1]])
        b.append([-1*a[1][0], a[0][0]])
        let determinant:Float = 1/(a[0][0]*a[1][1]-a[1][0]*a[0][1])
        b[0][0] = determinant*b[0][0]
        b[0][1] = determinant*b[0][1]
        b[1][0] = determinant*b[1][0]
        b[1][1] = determinant*b[1][1]
        return b
    }
    
    // pad vector with 1's
    func pad1(_ a:[Float]) -> [[Float]] {
        var b:[Float] = []
        var c:[Float] = []
        var d:[[Float]] = []
        for i in 0...a.count {
            b.append(a[i])
            c.append(1.0)
        }
        d.append(b)
        d.append(c)
        return d
    }
    
    func polyfit(_ a:[[Float]], _ y:[[Float]]) -> [[Float]] {
        var temp1: [[Float]] = matx(a, tpose(a))
        temp1 = inv2(temp1)
        let temp2 = matx(a, tpose(y))
        let coeffs = matx(temp1, temp2)
        return coeffs
    }
    
    func noise_comp(metric: [Float], loop:Int) -> Void {

    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            data_label.text = "BLE is powered on"
            print("BLE is powered on")
        } else {
            data_label.text = "BLE Error"
            print("BLE IS BROKEN")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let pname = peripheral.name {
            if pname == "ESP32" {
                self.centralManager.stopScan()
                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                self.centralManager.connect(peripheral, options: nil)
                data_label.text = "ESP32 is connected"
                print("ESP32 is connected")
                // This is for debugging purpose. Will remove after completion - Antonio
                //print("Peripheral Discovered: \(peripheral)")
                //print("Peripheral name: \(peripheral.name)")
                //print ("Advertisement Data : \(advertisementData)")
            }
        } else {
            print("Error on Connecting ESP32")
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
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
                print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("TX Characteristic: \(txCharacteristic.uuid)")
            }
        }
    }
}

extension ViewController: CBPeripheralManagerDelegate {
    
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
            print("X1: \(xAcc[counter]), X2: \(xAcc[counter+1]), Y1: \(yAcc[counter]), Y2: \(yAcc[counter+1]), Z1: \(zAcc[counter]), Z:2\(zAcc[counter+1])")
        
            data_label.text = "Parsing..."
        
             counter += 2
        } else {
            //process_data()
            // Add graphing stuff here
        }
        
    }	
}
