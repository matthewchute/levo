//
//  ResultsViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-07-12.
//

import UIKit
import CoreBluetooth

class ResultsViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    var xAcc: [Float] = []
    var yAcc: [Float] = []
    var zAcc: [Float] = []
    var packetNum: [Int] = []
    var counter: Int = 0
    var done_flag: Bool = false
    var sample_period: Float = 0.0
    
    @IBOutlet weak var data_label: UILabel!
    @IBOutlet weak var back_btn: UIButton!
    
    @IBAction func didTap(_ sender: Any) {
        let xdata: [Float] = xAcc
        let ydata: [Float] = yAcc
        let zdata: [Float] = zAcc
        let sp: Float = sample_period
        NotificationCenter.default.post(name: Notification.Name("xdata"), object: xdata)
        NotificationCenter.default.post(name: Notification.Name("ydata"), object: ydata)
        NotificationCenter.default.post(name: Notification.Name("zdata"), object: zdata)
        NotificationCenter.default.post(name: Notification.Name("sample"), object: sp)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        back_btn.setTitle("Back", for: .normal)
    }
    
    // parse str sent over ble and collect x y z accelerations and store them in respective array
    func parseString(str: String) -> Void {
        let stringArr: [String] = str.components(separatedBy: ",")
        if stringArr[0] == "EOF" {
            // disconnect peripheral connection
            sample_period = Float(stringArr[1]) ?? 0.0
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
            packetNum.append(Int(stringArr[18]) ?? 9999)
        }
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

extension ResultsViewController: CBPeripheralManagerDelegate {
    
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
            print("X1: \(xAcc[counter]), X2: \(xAcc[counter+1]), Packet: \(packetNum[counter/2])")
        
            data_label.text = "Parsing..."
        
             counter += 2
        } else {
            centralManager.cancelPeripheralConnection(myPeripheral)
        }
    }
}
