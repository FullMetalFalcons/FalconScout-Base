//
//  Bluetooth.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/9/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import CoreBluetooth


private let TRANSFER_SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
private let TRANSFER_CHARACTERISTIC_UUID = "54FDC536-71BA-4BF9-A854-FFDD989001D5"

public let TRANSFER_SERVICE_CBUUID: CBUUID = CBUUID(string: TRANSFER_SERVICE_UUID)
public let TRANSFER_CHARACTERISTIC_CBUUID: CBUUID = CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)

extension AppDelegate : CBCentralManagerDelegate {
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        var uuid = peripheral.identifier.UUIDString
        if availableDevices.objectForKey(uuid) == nil && peripheral.name != nil {
            availableDevices.setValue(peripheral, forKey: uuid)
            availableDevicesNames.addObject(peripheral.name)
            <>("advertisement with identifier: \(uuid),\n\tstate: \(peripheral.state),\n\tname: \(peripheral.name),\n\tservices: \(peripheral.services),\n\tdescription: \(advertisementData.description)")
            row__name__available[availableDevicesNames.count - 1] = peripheral.name
            name__device__available[peripheral.name] = peripheral
            self.tableAvailableDevices.reloadData()
        }
    }

    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        <>("Connected to \(peripheral.name)")
        connectedDevices.setValue(peripheral, forKey: peripheral.identifier.UUIDString)
        connectedDevicesNames.addObject(peripheral.name)
        peripheral.delegate = Periphery(peripheral.identifier.UUIDString)
        row__name__connected[connectedDevicesNames.count] = peripheral.name
        name__device__connected[peripheral.name] = peripheral
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        <>("central manager updated state")
    }
}
