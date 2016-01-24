
//
//  Table.swift
//  Central Scout
//

import Cocoa
import CoreBluetooth


extension AppDelegate : NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView {
        case self.tableAvailableDevices:
            return self.availableDevicesUUIDs.count
        case self.tableConnectedDevices:
            return self.connectedDevicesUUIDs.count
        default: return 0
        }
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: CellView?
        switch tableColumn!.identifier {
        case "available":
            let UUID = availableDevicesUUIDs.objectAtIndex(row).UUIDString
            let name: String? = uuidToName[UUID]
            view = CellView(name: name, uuid: UUID, RSSI: uuidToRSSI[UUID]! as! Int)
        case "connected":
            let UUID = connectedDevicesUUIDs.objectAtIndex(row).UUIDString
            let name: String? = uuidToName[UUID]
            view = CellView(name: name, uuid: UUID, RSSI: uuidToRSSI[UUID]! as! Int)
        default: break
        }
        return view
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView: NSTableView = notification.object! as! NSTableView
        let rowIndex = tableView.selectedRow
        let columnIndex = tableView.selectedColumn
        if rowIndex == -1 {
            self.selectedIndex = -1
            return
        }
        let cellView: CellView? = tableView.viewAtColumn(columnIndex, row: rowIndex, makeIfNecessary: true) as? CellView
        if let cell = cellView {
            let nsuuid = NSUUID(UUIDString: cell.UUID)
            selectedIndex = rowIndex
            if selectedIndex != -1 {
                switch tableView as NSObject {
                case self.tableAvailableDevices:
                    selectedColumn = 0
                    let device: CBPeripheral = uuidToDevice_available[nsuuid!] as! CBPeripheral
                    selectedDeviceAvailable = device
                    LOG("Selected from available devices named:: \(device.name), \(device.identifier.UUIDString)")
                case self.tableConnectedDevices:
                    selectedColumn = 1
                    let device: CBPeripheral = uuidToDevice_connected[nsuuid!] as! CBPeripheral
                    selectedDeviceConnected = device
                    LOG("Selected from connected devices named:: \(device.name), \(device.identifier.UUIDString)")
                default:
                    selectedColumn = -1
                    break
                }
            }
        }
    }
}
