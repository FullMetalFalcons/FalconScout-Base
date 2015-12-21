//
//  BTRef.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/6/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import CoreBluetooth
import Cocoa

private var theData = NSMutableData()
private var fileCount = 0
extension AppDelegate: CBPeripheralDelegate {
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service: CBService in peripheral.services as [CBService]! {
            <>"Found service \(service)"
            <>"\tFinding characteristics of this service..."
            peripheral.discoverCharacteristics([UUID_CHARACTERISTIC], forService: service)
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        _ = NSMutableArray()
        for char in service.characteristics! {
            let aCharacteristic: CBCharacteristic = char as CBCharacteristic;
            //            potentialUIDs.addObject(aCharacteristic.UUID)
            <>"\t\tFound characteristic \(aCharacteristic)"
            peripheral.setNotifyValue(true, forCharacteristic: aCharacteristic)
        }
        /*
        if !potentialUIDs.containsObject(UUID_CHARACTERISTIC) {
        self.manager.cancelPeripheralConnection(peripheral)
        self.updateTableDisconnect(peripheral)
        }*/
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        let data = characteristic.value
        <>"Received \(data!.length) bytes of data"
        let error: NSError? = nil
        
        if error != nil {
            <>"error discovering characteristic: \(error)"
            return
        }
        let stringFromData = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        if let str = stringFromData {
            if str.isEqualToString("EOM") {
                <>"DONE- Data size = \(theData.length)"
                let finalData = theData as NSData
                do {
                    let dictionary = try NSJSONSerialization.JSONObjectWithData(finalData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    let filesDirectory = currentDirectory.stringValue
                    let name = NSUUID().UUIDString
                    let didWrite = dictionary!.writeToFile("\(filesDirectory)/\(name).plist", atomically: true)
                    <>"did write = \(didWrite)"
                    self.lblReceivedFiles.stringValue = "\(++fileCount)"
                } catch {
                    <>"problem turning data back into dictionry:: \(error)"
                }
                /*
                if let dictionary = NSJSONSerialization.JSONObjectWithData(finalData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                var filesDirectory = currentDirectory.stringValue
                let name = NSUUID().UUIDString
                var didWrite = dictionary.writeToFile("\(filesDirectory)/\(name).plist", atomically: true)
                <>"did write = \(didWrite)"
                self.lblReceivedFiles.stringValue = "\(++fileCount)"
                }
                */
                theData = NSMutableData()
            }  else {
                theData.appendData(data!)
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        <>"update notification state"
        if characteristic.isNotifying {
            <>"IS NOTIFYING"
        } else {
            <>"NOT NOTIFYING"
            self.manager.cancelPeripheralConnection(peripheral)
            self.updateTableDisconnect(peripheral)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        <>"update write value for characteristic"
        
    }
}


