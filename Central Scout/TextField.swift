//
//  TextField.swift
//  Central Scout
//

import CoreBluetooth
import Cocoa

private var startText: String!
private var endText: String!

extension AppDelegate : NSControlTextEditingDelegate, NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing(obj: NSNotification) {
        if obj.object! as! NSObject == currentDirectory {
            startText = currentDirectory.stringValue
        } else if obj.object! as! NSObject == javaDirectory {}
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if obj.object! as! NSObject == currentDirectory {
            if currentDirectory.stringValue.hasSuffix("/") {
                currentDirectory.stringValue.removeAtIndex(currentDirectory.stringValue.endIndex.predecessor())
            }
            endText = currentDirectory.stringValue
            if startText != nil {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(startText)
                } catch {
                    LOG(error)
                }
            }
            if !NSFileManager.defaultManager().fileExistsAtPath(endText) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(endText, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    LOG(error)
                }
            }
        } else if obj.object! as! NSObject == javaDirectory {
            if javaDirectory.stringValue.hasSuffix("/") {
                javaDirectory.stringValue.removeAtIndex(javaDirectory.stringValue.endIndex.predecessor())
            }
            if !NSFileManager.defaultManager().fileExistsAtPath(obj.object!.stringValue) {
                if self.panels.selectedTabViewItem?.label == "Export Data" {
                    LOG("Checking validity of jar")
                    if isDirectory(obj.object!.stringValue) {
                        alert("Cannot be a directory. Must be a java .jar file")
                    } else {
                        alert("No jar file exists there")
                    }
                }
            }
        } else if obj.object! as! NSObject == txtPasskey {
            self.passkey = self.txtPasskey.stringValue
            if !isValidID(self.passkey) {
                alert("That is not a valid password- it must be 4 characters long, consiting of either numbers or letters A-F")
                return
            }
            UUID_SERVICE = CBUUID(string: self.passkey)
            self.refresh()
            LOG("passkey is \(self.passkey)")
        } else if obj.object! as! NSObject == configFileLocation {
            if configFileLocation.stringValue.hasSuffix("/") {
                configFileLocation.stringValue.removeAtIndex(configFileLocation.stringValue.endIndex.predecessor())
            }
            if !NSFileManager.defaultManager().fileExistsAtPath(obj.object!.stringValue) {
                LOG("Checking validity of config")
                if isDirectory(obj.object!.stringValue) {
                    alert("Cannot be a directory. Must be a .txt file")
                } else {
                    alert("No text file exists there")
                }
            }
        }
    }
}
