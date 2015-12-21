//
//  ExportData.swift
//  Central Scout
//
//  Created by Alex DeMeo on 2/4/15.
//  Copyright (c) 2015 Alex DeMeo. All rights reserved.
//

import Cocoa

extension AppDelegate {
    @IBAction func compile(sender: AnyObject) {
        let dir = javaDirectory.stringValue
        let filesDirectory = currentDirectory.stringValue
        <>"Compiling to excel by executing java in directory: \(dir)"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            bash("java -jar \(dir) \(filesDirectory)")
        })
    }
}
