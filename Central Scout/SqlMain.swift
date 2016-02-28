//
//  SqlMain.swift
//  Central Scout
//
//  Created by Alex DeMeo on 2/17/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import Cocoa
import CoreBluetooth

struct DatabaseManager {
    var hasDB: Bool!
    var arrResults: NSMutableArray!
    var arrColumns: NSMutableArray!
    var affectedRows: Int!
    var lastInsertedRowID: Int!
    
    var theDatabase: COpaquePointer = nil
    
    init() {
        self.open()
    }
    
    mutating func open() {
        if !NSFileManager.defaultManager().fileExistsAtPath(DatabaseManager.getDBLocation()) {
            LOG("No db there, not opening db")
            self.hasDB = false
            return
        }
        if sqlite3_open(DatabaseManager.getDBLocation(), &self.theDatabase) != SQLITE_OK {
            LOG("Could not open database")
            self.hasDB = false
        } else {
            LOG("Opened database")
            self.hasDB = true
        }
    }
    
    internal mutating func retrieveTeamOnPeripheral(peripheral: CBPeripheral, withCharacteristic characteristic: CBCharacteristic, teamNum: String) {
        var statement: COpaquePointer = nil
        
        if sqlite3_prepare_v2(self.theDatabase, "SELECT * FROM team_data WHERE team_num=\(teamNum);", -1, &statement, nil) != SQLITE_OK {
            LOG("Failed to read table")
            peripheral.writeValue("NoReadTable".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            return
        } else {
            LOG("Read table, stored to info: \(statement)")
        }
        
        let didStep = sqlite3_step(statement)
        if didStep != SQLITE_ROW {
            LOG("Could not read stored table info from statement, error code is: \(String.fromCString(sqlite3_errmsg(self.theDatabase)))")
            peripheral.writeValue("NoReadTeam".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            return
        } else {
            let numColumns = sqlite3_column_count(statement)
            let teamNum = sqlite3_column_int64(statement, 0)
            var teamDict = ""
            LOG("READ data for team: \(teamNum)")
            for i in 0..<numColumns {
                let colTitle = sqlite3_column_name(statement, i)
                let colTitleIntPtr = UnsafePointer<Int8>(colTitle)
                let colTitleStr = String.fromCString(colTitleIntPtr)!
                let colInfo = sqlite3_column_text(statement, i)
                let colInfoIntPtr = UnsafePointer<Int8>(colInfo)
                let colInfoStr = String.fromCString(colInfoIntPtr)!
                teamDict = "\(teamDict)[\(colTitleStr)=\(colInfoStr)]"
            }
            let allTeamData = teamDict.dataUsingEncoding(NSUTF8StringEncoding)!
            
            for data in allTeamData.toDataArray(75) {
                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            }
            peripheral.writeValue("EOM".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(self.theDatabase))
            print("error finalizing prepared statement: \(errmsg)")
        }
        statement = nil
    }
    
    mutating func close() {
        if sqlite3_close(self.theDatabase) != SQLITE_OK {
            LOG("Error closing database")
        } else {
            LOG("Successfully closed database")
        }
        self.theDatabase = nil
    }
    
    static func getDBDirectory() -> String {
        return AppDelegate.instance().javaDirectory.stringValue.substringToIndex((AppDelegate.instance().javaDirectory.stringValue.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil)?.startIndex)!)
    }
    
    static func getDBLocation() -> String {
        return "\(DatabaseManager.getDBDirectory())/scouting.db"
    }
}

extension NSData {
    func toDataArray(MTU: Int) -> [NSData] {
        print("LENGTH: \(self.length)")
        var index = 0
        var arr = [NSData]()
        let lastBit = self.length % MTU
        let nIterations = (self.length - lastBit) / MTU
        for i in 0...nIterations {
            let chunk = NSData(bytes: self.bytes + index, length: i == nIterations ? lastBit : MTU)
            arr.append(chunk)
            index += MTU
        }
        return arr
    }
}


