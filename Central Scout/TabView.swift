//
//  TabView.swift
//  Central Scout
//
//  Created by Alex DeMeo on 2/4/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import Cocoa


extension AppDelegate : NSTabViewDelegate {
    func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        switch tabViewItem!.label {
        case "Export Data":
            initSaveDirectory()
            if !NSFileManager.defaultManager().fileExistsAtPath(javaDirectory.stringValue) {
                alert("No java jar exists at the selected path\nPlease specify where it is")
            }
            self.window.makeFirstResponder(self.btnExportExcel)
        default:
            return
        }
    }
    
    func initSaveDirectory() {
        if !NSFileManager.defaultManager().fileExistsAtPath(currentDirectory.stringValue) {
//            var error: NSError?
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(self.currentDirectory.stringValue, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
            
//            NSFileManager.defaultManager().createDirectoryAtPath(currentDirectory.stringValue, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
    }
}
