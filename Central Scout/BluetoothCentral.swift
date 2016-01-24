//
//  Bluetooth.swift
//  Central Scout
//

import CoreBluetooth

public var UUID_SERVICE: CBUUID = CBUUID(string: "444B")
public let UUID_CHARACTERISTIC: CBUUID = CBUUID(string: "200B")

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
//        if selectedDeviceAvailable != nil {
//            self.updateTableConnect(selectedDeviceAvailable!)
//        }
        self.updateTableConnect(peripheral)
        selectedDeviceAvailable = nil
        if !connectedDevicesUUIDs.containsObject(peripheral.identifier) {
            connectedDevicesUUIDs.addObject(peripheral.identifier)
        }
        uuidToDevice_connected[peripheral.identifier] = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([UUID_SERVICE])
    }
    
    func centralManager(central: CBCentralManager,didDisconnectPeripheral peripheral: CBPeripheral,error: NSError?) {
        LOG("Disconnected from \(peripheral.name)")
        self.updateTableDisconnect(peripheral)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            LOG("Central manager state POWERED ON")
            self.refresh()
            //            manager.scanForPeripheralsWithServices([UUID_SERVICE], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        }
    }
}
