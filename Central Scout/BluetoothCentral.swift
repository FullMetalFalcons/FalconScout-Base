//
//  Bluetooth.swift
//  Central Scout
//

import CoreBluetooth
import Cocoa

public var UUID_SERVICE: CBUUID = CBUUID(string: "444B")
public let UUID_CHARACTERISTIC: CBUUID = CBUUID(string: "20D0C428-B763-4016-8AC6-4B4B3A6865D9")

extension AppDelegate : CBCentralManagerDelegate {
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let uuid = peripheral.identifier.UUIDString
        self.uuidToName[uuid] = peripheral.name
        self.uuidToRSSI[uuid] = RSSI
        if !availableDevicesUUIDs.containsObject(peripheral.identifier) {
            availableDevicesUUIDs.addObject(peripheral.identifier)
        }
        uuidToDevice_available[peripheral.identifier] = peripheral
        LOG("advertisement with identifier: \(uuid),\n\tstate: \(peripheral.state),\n\tname: \(peripheral.name),\n\tservices: \(peripheral.services),\n\tdescription: \(advertisementData.description),\n\tRSSI: \(RSSI)")
        self.reloadTableData()
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] == nil {
            return
        }
        self.manager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        LOG("Connected to \(peripheral.name)")
        self.updateTableConnect(peripheral)
        selectedDeviceAvailable = nil
        if !connectedDevicesUUIDs.containsObject(peripheral.identifier) {
            connectedDevicesUUIDs.addObject(peripheral.identifier)
        }
        uuidToDevice_connected[peripheral.identifier] = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([UUID_SERVICE])
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        LOG("Disconnected from \(peripheral.name)")
        self.updateTableDisconnect(peripheral)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            LOG("Central manager state POWERED ON")
            self.refresh()
        case .PoweredOff:
            LOG("Bluetooth is OFF")
            alert("Bluetooth is appears to be off, please turn it on", pullsDown: NSApp.mainWindow != nil, onCompletion: {})
        case .Unsupported:
            LOG("Ble not supported on device")
            alert("Bluetooth Low Energy (BLE) is not supported on this device\tPlease use this app on a device that supports BLE\nThe program will now exit", pullsDown: NSApp.mainWindow != nil, onCompletion: {
                _ -> () in
                exit(0)
            })
        default:
            LOG("Changed state to \(central.state)")
        }
    }
}
