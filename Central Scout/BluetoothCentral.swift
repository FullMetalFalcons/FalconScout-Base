//
//  Bluetooth.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/9/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import CoreBluetooth

public var UUID_SERVICE: CBUUID = CBUUID(string: "444B")
public let UUID_CHARACTERISTIC: CBUUID = CBUUID(string: "200B")

extension AppDelegate : CBCentralManagerDelegate {
    
    func space(num: Int) {
        for _ in 0..<num {
            print("")
        }
    }
    
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let uuid = peripheral.identifier.UUIDString
        uuidToName[uuid] = peripheral.name
        if !existingDevices.containsObject(uuid) {
            existingDevices.addObject(uuid)
            
            availableDevicesUUIDs.addObject(peripheral.identifier)
            uuidToDevice_available[peripheral.identifier] = peripheral

            <>("advertisement with identifier: \(uuid),\n\tstate: \(peripheral.state),\n\tname: \(peripheral.name),\n\tservices: \(peripheral.services),\n\tdescription: \(advertisementData.description)")
            
            update()
        }
        
        
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] == nil {
            return
        }
        let t1: String = advertisementData[CBAdvertisementDataServiceUUIDsKey]![0]!.description
        let t2: String = "Unknown (<\(UUID_SERVICE.UUIDString.lowercaseString)>)"
  
        if t1 == t2 {
            self.manager.connectPeripheral(peripheral, options: nil)
        } else {
            self.manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        <>("Connected to \(peripheral.name)")

        if selectedDeviceAvailable != nil {
            updateTableConnect(selectedDeviceAvailable!)
        }
        selectedDeviceAvailable = nil
        
        connectedDevicesUUIDs.addObject(peripheral.identifier)
        uuidToDevice_connected[peripheral.identifier] = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([UUID_SERVICE])
    }
    
    func centralManager(central: CBCentralManager,didDisconnectPeripheral peripheral: CBPeripheral,error: NSError?) {
        <>"Disconnected from \(peripheral.name)"
        updateTableDisconnect(peripheral)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            <>"Central manager state POWERED ON"
            manager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        }
    }
}
