//
//  Button.swift
//  Central Scout
//

import Cocoa
import CoreBluetooth

extension AppDelegate {
    
    private func getSelectionDirectory(filetype: String, executable: (String?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Java Scouting jar"
        openPanel.showsResizeIndicator = false
        openPanel.showsHiddenFiles = false
        openPanel.allowsMultipleSelection = false
        if filetype != "directory" {
            openPanel.allowedFileTypes = [filetype]
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
        } else {
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
        }
        openPanel.beginSheetModalForWindow(AppDelegate.instance().window, completionHandler: {
            result in
            if result == NSModalResponseOK {
                executable(openPanel.URLs[0].path)
            }
        })
    }
    
    @IBAction func getJavaExecutableDirectory(sender: NSButton) {
        self.database.close()
        self.getSelectionDirectory("jar", executable: {
            path in
            self.javaDirectory.stringValue = path == nil ? "None" : path!
            self.database.open()
        })
    }
    
    @IBAction func getCurrentScoutingDirectory(sender: NSButton) {
        self.getSelectionDirectory("directory", executable: {
            path in
            self.currentDirectory.stringValue = path == nil ? "None" : path!
        })
    }
    
    @IBAction func compile(sender: NSButton) {
        let dir = javaDirectory.stringValue
        let filesDirectory = currentDirectory.stringValue
        let configLoc = configFileLocation.stringValue
        if !NSFileManager.defaultManager().fileExistsAtPath(javaDirectory.stringValue) {
            alert("Please specify a location of the Scouting program Java executable file to be able to compile the information into Excel")
            return
        }
        LOG("Compiling to excel by executing java in directory: \(dir)")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let newDir = filesDirectory.substringToIndex((filesDirectory.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil)?.startIndex)!)
            LOG("results.xlsx will be located at: \(newDir)")
            bash("java -jar \(dir.toBashDir()) \(configLoc.toBashDir()) \(filesDirectory.toBashDir()) \(DatabaseManager.getDBDirectory().toBashDir()) true \(newDir.toBashDir())")
        })
    }
    
    @IBAction func btnUpdateDB(sender: NSButton) {
        self.timerUpdateDB.fire()
    }
    
    /**
     Save the LOG, because why not
     */
    @IBAction func saveLogToFile(sender: AnyObject) {
        let allText = self.logView.textStorage?.string
        self.getSelectionDirectory("directory", executable: {
            path in
            do {
                if path == nil {
                    return
                }
                try allText?.writeToFile("\(path!)/LOG.txt", atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                LOG(error)
            }
        })
    }
    
    
    /**
     Refresh scanning
     */
    @IBAction func btnRefresh(sender: NSButton) {
        self.refresh()
    }
    
    @IBAction func getConfigLocation(sender: NSButton) {
        self.getSelectionDirectory("txt", executable: {
            path in
            self.configFileLocation.stringValue = path == nil ? "None" : path!
        })
    }
    
    func refresh() {
        LOG("Refreshing...")
        self.btnRefresh.enabled = false
        manager.stopScan()
        manager.scanForPeripheralsWithServices([UUID_SERVICE], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        manager.retrievePeripheralsWithIdentifiers(self.availableDevicesUUIDs as AnyObject as! [NSUUID])
        self.reloadTableData()
        var cnt = 0;
        var t: NSTimer!
        t = NSTimer.scheduledTimerWithTimeInterval(0.0055555556, repeats: true, block: {
            _ in
            cnt += 1
            if cnt >= 180 {
                self.btnRefresh.enabled = true
                t.invalidate()
            } else {
                self.btnRefresh.image = self.btnRefresh.image?.rotateByDegrees(4)
            }
        })
    }
    
    @IBAction func resetDB(sender: NSButton) {
        LOG("Reset database")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(DatabaseManager.getDBLocation())
        } catch {
            alert("Couldn't remove database\nIt probably doesn't exist")
        }
    }
}
