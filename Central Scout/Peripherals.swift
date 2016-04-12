



import CoreBluetooth
import Cocoa

//private var theData = NSMutableData()
private var fileCount = 0
var periphToData = [String : NSMutableData]()
extension AppDelegate: CBPeripheralDelegate {
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service: CBService in peripheral.services as [CBService]! {
            LOG("Found service \(service)")
            if service.UUID.UUIDString == UUID_SERVICE.UUIDString {
                LOG("\tFinding characteristics of this service...")
                peripheral.discoverCharacteristics([UUID_CHARACTERISTIC_ROBOT, UUID_CHARACTERISTIC_DB], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for char in service.characteristics! {
            let characteristic: CBCharacteristic = char as CBCharacteristic;
            if characteristic.UUID.UUIDString == UUID_CHARACTERISTIC_ROBOT.UUIDString {
                LOG("\t\tSetting peripheral \(peripheral.name) to notify for characteristic \(characteristic.UUID.UUIDString)- This is the send data characteristic")
            } else if characteristic.UUID.UUIDString == UUID_CHARACTERISTIC_DB.UUIDString {
                LOG("\t\tSetting peripheral \(peripheral.name) to notify for characteristic \(characteristic.UUID.UUIDString)- This is the request data characteristic")
            }
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID == UUID_CHARACTERISTIC_ROBOT {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                let data = characteristic.value
                LOG("Received \(data!.length) bytes of data")
                let error: NSError? = nil
                if error != nil {
                    LOG("error discovering characteristic: \(error)")
                    return
                }
                
                let stringFromData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                let id = peripheral.identifier.UUIDString
                if periphToData[id] == nil {
                    periphToData[id] = NSMutableData()
                }

                if let str = stringFromData {
                    if str.isEqualToString("EOM") {
                        LOG("DONE- Data size = \(periphToData[id]!.length)")
                        let finalData = periphToData[id]! as NSData
                        do {
                            let filesDirectory = self.currentDirectory.stringValue
                            let name = NSUUID().UUIDString
                            let everything = NSString(data: finalData, encoding: NSUTF8StringEncoding)
                            try everything!.writeToFile("\(filesDirectory)/\(name).plist", atomically: true, encoding: NSUTF8StringEncoding)
                            LOG("Writing value")
                            fileCount += 1
                            self.lblReceivedFiles.stringValue = "\(fileCount)"
                        } catch {
                            LOG("problem turning data back into dictionary:: \(error)")
                        }
                        periphToData[id] = NSMutableData()
                    }  else {
                        periphToData[id]!.appendData(data!)
                    }
                }
            })
        } else if characteristic.UUID == UUID_CHARACTERISTIC_DB {
            let number = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            if let req = number {
                LOG("Got request– \(req)")
                let parts = req.componentsSeparatedByString("::")
                if parts[0].hasPrefix("n") {
                    self.database.retrieveTeamOnPeripheral(peripheral, withCharacteristic: characteristic, teamNum: "\(parts[1])")
                } else if parts[0].hasPrefix("i") {
                    self.database.retrieveInfoOnPeripheral(peripheral, withCharacteristic: characteristic, withInfo: parts[1].componentsSeparatedByString(";;"))
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.isNotifying {
            LOG("IS NOTIFYING- \(peripheral.name), characteristic: \(characteristic.UUID.UUIDString)")
        } else {
            LOG("NOT NOTIFYING- \(peripheral.name), disconnecting")
            self.manager.cancelPeripheralConnection(peripheral)
            peripheral.setNotifyValue(false, forCharacteristic: characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
    }
}