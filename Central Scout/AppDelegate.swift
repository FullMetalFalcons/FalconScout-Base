//
//  AppDelegate.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/5/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import CoreBluetooth
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var logView: NSTextView!
    @IBOutlet var currentDirectory: NSTextField!
    @IBOutlet var javaDirectory: NSTextField!
    @IBOutlet var tableAvailableDevices: NSTableView!
    @IBOutlet var tableConnectedDevices: NSTableView!
    @IBOutlet var panels: NSTabView!
    @IBOutlet var btnExportExcel: NSButton!
    @IBOutlet var lblReceivedFiles: NSTextField!
    @IBOutlet var txtPasskey: NSTextField!
    
    var existingDevices = NSMutableArray()
    
    var manager: CBCentralManager!
    
    var availableDevicesUUIDs = NSMutableArray()
    var connectedDevicesUUIDs = NSMutableArray()
    
    var uuidToDevice_available = NSMutableDictionary()
    var uuidToDevice_connected = NSMutableDictionary()
    var uuidToName = [String : String]()
    var selectedIndex = -1
    var selectedColumn = -1
    
    var selectedDeviceAvailable: CBPeripheral?
    var selectedDeviceConnected: CBPeripheral?
    
    var passkey: String!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        <>("Starting Bluetooth...")
        self.manager = CBCentralManager(delegate: self, queue: nil, options: nil)
//        self.manager.scanForPeripheralsWithServices(nil, options: nil)
        window.delegate = self
        logView.editable = false
        currentDirectory.delegate = self
        javaDirectory.delegate = self
        txtPasskey.delegate = self
        panels.delegate = self
        tableAvailableDevices.setDelegate(self)
        tableAvailableDevices.setDataSource(self)
        tableConnectedDevices.setDelegate(self)
        tableConnectedDevices.setDataSource(self)
        
        currentDirectory.stringValue = "\(applicationDesktopDirectory())/Scout"
        javaDirectory.stringValue = "\(applicationDesktopDirectory())/Scout.jar"
        
        self.initSaveDirectory()
    }
    
    /**
     Refresh scanning, not very useful considering it's always scanning but just in case
     */
    @IBAction func refresh(sender: AnyObject?) {
        <>"Refreshing..."
        manager.stopScan()
        manager.scanForPeripheralsWithServices(nil, options: nil)
        self.update()
    }
    
    /**
     Called to disconnect device from selected available device
     */
    @IBAction func connect(sender: AnyObject?) {
        if selectedIndex != -1 {
            if selectedColumn == 0 {
                if let device = selectedDeviceAvailable {
                    <>"attempting to connect to \(device.name)"
                    self.manager.connectPeripheral(device, options: [CBAdvertisementDataServiceUUIDsKey : [UUID_SERVICE]])
                    NSTimer.scheduledTimerWithTimeInterval(2, repeats: false, block: {
                        () -> Void in
                        if device.state != CBPeripheralState.Connected {
                            alert("Could not connected to \(device.name == nil ? "No name" : device.name!), maybe they passkeys don't match up")
                        }
                    })
                   
                }
            } else {
                <>"Device is already connected"
                alert("device already connected")
            }
        } else {
            <>"no device selected"
            alert("no device selected")
        }
    }
    
    /**
     Called to disconnect device from selected connected device
     */
    @IBAction func disconnect(sender: AnyObject?) {
        if selectedIndex != -1  {
            if selectedColumn == 1 {
                if let device = selectedDeviceConnected {
                    self.updateTableDisconnect(selectedDeviceConnected!)
                    selectedDeviceConnected = nil
                    self.manager.cancelPeripheralConnection(device)
                }
            } else {
                <>"Can't disconnect from a device that isn't connected"
                alert("Can't disconnect from a device that isn't connected")
            }
        } else {
            <>"no device selected"
            alert("no device selected")
        }
    }
    
    func updateTableConnect(peripheral: CBPeripheral) {
        self.availableDevicesUUIDs.removeObject(peripheral.identifier)
        self.uuidToDevice_available.removeObjectForKey(peripheral.identifier)
        self.connectedDevicesUUIDs.addObject(peripheral.identifier)
        self.uuidToDevice_connected[peripheral.identifier] = peripheral
        removeDuplicates(&self.availableDevicesUUIDs)
        removeDuplicates(&self.connectedDevicesUUIDs)
        update()
    }
    
    func updateTableDisconnect(peripheral: CBPeripheral) {
        self.connectedDevicesUUIDs.removeObject(peripheral.identifier)
        self.uuidToDevice_connected.removeObjectForKey(peripheral.identifier)
        self.availableDevicesUUIDs.addObject(peripheral.identifier)
        self.uuidToDevice_available[peripheral.identifier] = peripheral
        removeDuplicates(&self.availableDevicesUUIDs)
        removeDuplicates(&self.connectedDevicesUUIDs)
        update()
    }
    
    @IBAction func generateUUID(sender: NSButton) {
        self.txtPasskey.stringValue = genID()
        self.passkey = self.txtPasskey.stringValue
        self.controlTextDidEndEditing(NSNotification(name: "", object: self.txtPasskey))
    }
}
