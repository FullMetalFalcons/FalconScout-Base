
//
//  Table.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/7/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import Cocoa
import CoreBluetooth


//private var existingAvail = NSMutableArray()

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
    /*
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
    switch tableColumn!.identifier {
    case "available":
    return availableDevicesUUIDs.objectAtIndex(row).UUIDString
    case "connected":
    return connectedDevicesUUIDs.objectAtIndex(row).UUIDString
    default: return nil
    }
    }
    */
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: CellView?
        switch tableColumn!.identifier {
        case "available":
            let UUID = availableDevicesUUIDs.objectAtIndex(row).UUIDString
            let name: String? = uuidToName[UUID]
            view = CellView(name: name == nil ? "No name" : name, uuid: UUID)
        case "connected":
            let UUID = connectedDevicesUUIDs.objectAtIndex(row).UUIDString
            let name: String? = uuidToName[UUID]
            view = CellView(name: name == nil ? "No name" : name, uuid: UUID)
        default: break
        }
        return view
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView: NSTableView = notification.object! as! NSTableView
        let rowIndex = tableView.selectedRow
        let columnIndex = tableView.selectedColumn
        if rowIndex == -1 {
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
                    <>"Selected from available devices named:: \(device.name), \(device.identifier.UUIDString)"
                    
                case self.tableConnectedDevices:
                    selectedColumn = 1
                    let device: CBPeripheral = uuidToDevice_connected[nsuuid!] as! CBPeripheral
                    selectedDeviceConnected = device
                    <>"Selected from connected devices named:: \(device.name), \(device.identifier.UUIDString)"
                    
                default:
                    selectedColumn = -1
                    break
                }
            }
        }
        
    }
    
    /*
    func tableViewSelectionDidChange(notification: NSNotification) {
    let tableView: NSTableView = notification.object! as! NSTableView
    let rowIndex = tableView.selectedRow
    let cell: NSCell! = tableView.preparedCellAtColumn(0, row: rowIndex)
    
    if cell != nil {
    let NAME: String = cell.stringValue
    selectedIndex = rowIndex
    if selectedIndex != -1 {
    switch tableView as NSObject {
    case self.tableAvailableDevices:
    selectedColumn = 0
    //                    let rowView: AnyObject! = tableAvailableDevices.viewAtColumn(0, row: selectedIndex, makeIfNecessary: true)
    let nsuuid = NSUUID(UUIDString: NAME)
    let device: CBPeripheral! = uuidToDevice_available[nsuuid!] as! CBPeripheral;
    selectedDeviceAvailable = device
    <>"Selected from available devices:: \(device.name)"
    case self.tableConnectedDevices:
    selectedColumn = 1
    //                    let rowView: AnyObject! = tableConnectedDevices.viewAtColumn(0, row: selectedIndex, makeIfNecessary: true)
    let nsuuid = NSUUID(UUIDString: NAME)
    let device = uuidToDevice_connected[nsuuid!] as! CBPeripheral
    selectedDeviceConnected = device
    <>"Selected from connected devices:: \(device.name)"
    default:
    selectedColumn = -1
    return
    }
    }
    }
    }*/
}


class CellView: NSTextField {
    internal var UUID: String!
    internal var name: String?
    
    init(name: String?, uuid: String) {
        super.init(frame: NSRect())
        self.editable = false
        
        self.name = name
        self.UUID = uuid
        
        Swift.print("\(name) + \(UUID)")
        if name != nil {
            self.stringValue = self.name!
        } else {
            self.stringValue = self.UUID
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}