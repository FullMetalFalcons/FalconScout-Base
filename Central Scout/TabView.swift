//
//  TabView.swift
//  Central Scout
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
            if !NSFileManager.defaultManager().fileExistsAtPath(configFileLocation.stringValue) {
                alert("No config exists at that path\nPlease specify where it is")
            }
            self.window.makeFirstResponder(self.btnExportExcel)
        default:
            return
        }
    }
    
    func initSaveDirectory() {
        if !NSFileManager.defaultManager().fileExistsAtPath(currentDirectory.stringValue) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(self.currentDirectory.stringValue, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
    }
}
