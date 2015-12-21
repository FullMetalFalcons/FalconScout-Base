//
//  Delegate.swift
//  Central Scout
//
//  Created by Alex DeMeo on 1/6/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import Cocoa


extension NSTextView {
    func appendText(text: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let attr = NSAttributedString(string: text)
            self.textStorage?.appendAttributedString(attr)
            self.scrollRangeToVisible(NSMakeRange(self.string!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), 0))
        })
    }
}


extension NSMutableDictionary {
    func hasObjectForKey(key: String) -> Bool {
        return self.objectForKey(key) != nil
    }
}


extension AppDelegate {
    /**
     Returns the current instance of the app
     */
    class func instance() -> AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }
    
    /**
     Save the log, because why not
     */
    @IBAction func saveLogToFile(sender: AnyObject) {
        let allText = self.logView.textStorage?.string
        do {
        try allText?.writeToFile("\(applicationDocumentsDirectory())/log.txt", atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            <>error
        }
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    /**
     Reloads data for both tables
     */
    func update() {
        self.tableAvailableDevices.reloadData()
        self.tableConnectedDevices.reloadData()
    }
}



class CCell : NSCell {
    var uuidValue: String = ""
}