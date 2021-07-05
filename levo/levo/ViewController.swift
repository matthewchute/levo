//
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
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            data_label.text = "BLE is powered on"
            print("BLE is pwoered on")
        } else {
            data_label.text = "BLE Error"
            print("BLE IS BROKEN")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let pname = peripheral.name {
            if pname == "esp32" {
                self.centralManager.stopScan()
                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                self.centralManager.connect(peripheral, options: nil)
                data_label.text = "ESP32 is connected"
            }
        } else {
            print("Error on Connecting ESP32")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    @IBAction func connect_button(_ sender: Any) {
        
    }
    
    @IBAction func disconnect_button(_ sender: Any) {
    }
    
    @IBOutlet weak var data_label: UILabel!
}

