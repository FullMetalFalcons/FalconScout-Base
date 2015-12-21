//
//  TextField.swift
//  Central Scout
//
//  Created by Alex DeMeo on 2/4/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
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
            endText = currentDirectory.stringValue
            if startText != nil {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(startText)
                } catch {
                    <>error
                }
            }
            
            if !NSFileManager.defaultManager().fileExistsAtPath(endText) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(endText, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    <>error
                }
            }
        } else if obj.object! as! NSObject == javaDirectory {
            if !NSFileManager.defaultManager().fileExistsAtPath(obj.object!.stringValue) {
                if self.panels.selectedTabViewItem?.label == "Export Data" {
                    <>"Checking validity of jar"
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
            <>"passkey is \(self.passkey)"
            
        }
    }
}
