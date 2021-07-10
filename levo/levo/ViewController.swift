
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
    
    var xAcc: [String] = []
    var yAcc: [String] = []
    var zAcc: [String] = []
    var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBOutlet weak var data_label: UILabel!
    
    // parse str sent over ble and collect x y z accelerations and store them in respective array
    func parseString(str: String) -> Void {
        let stringArr: [String] = str.components(separatedBy: ",")
        xAcc.append(stringArr[0])
        xAcc.append(stringArr[9])
        yAcc.append(stringArr[1])
        yAcc.append(stringArr[10])
        zAcc.append(stringArr[2])
        zAcc.append(stringArr[11])
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
                print("Peripheral Discovered: \(peripheral)")
                print("Peripheral name: \(peripheral.name)")
                print ("Advertisement Data : \(advertisementData)")
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
        
        print("X1: \(xAcc[counter]), X2: \(xAcc[counter+1]), Y1: \(yAcc[counter]), Y2: \(yAcc[counter+1]), Z1: \(zAcc[counter]), Z:2\(zAcc[counter+1])")
        
        if counter % 6 == 0 {data_label.text = "Parsing."}
        else if counter % 6 == 2 {data_label.text = "Parsing.."}
        else {data_label.text = "Parsing..."}
        
        counter += 2
        
        
        if counter >= 280 {
            // create graph. Note: Need to end peripheral scan, but i dont know how to do that.
            
        }
    }
}
