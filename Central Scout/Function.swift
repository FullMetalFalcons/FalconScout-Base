//
//  Function.swift
//  Central Scout
//

import Cocoa

func bash(args: String...) {
    var string = ""
    for s in args {
        string += "\(s) ;"
    }
    system(string)
}


private var count = 0
func LOG<T>(obj: T) {
    let sayWhat = "\(++count) –> \t\(obj)\n"
    AppDelegate.instance().logView.appendText(sayWhat)
    print(sayWhat)
}


public func applicationDocumentsDirectory() -> String! {
    let paths = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
    let documentsURL = paths[0] as NSURL
    return documentsURL.relativePath!
}

public func applicationDesktopDirectory() -> String! {
    let paths = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DesktopDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
    let documentsURL = paths[0] as NSURL
    return documentsURL.relativePath!
}

func alert(message: String, pullsDown: Bool, onCompletion: () -> ()) {
    LOG(message)
    let alert = NSAlert()
    alert.addButtonWithTitle("OK")
    alert.messageText = message
    if !pullsDown {
        if alert.runModal() == NSAlertFirstButtonReturn {
            onCompletion()
        }
    } else {
        alert.beginSheetModalForWindow(NSApp.mainWindow!, completionHandler: {
            response -> () in
            if response == NSAlertFirstButtonReturn {
                onCompletion()
            }
        })
    }
    
}
func alert(message: String) {
    alert(message, pullsDown: true, onCompletion: {
        _ -> () in
    })
}

func isDirectory(path: String) -> Bool {
    var isDir: ObjCBool = false
    if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) {
        return isDir.boolValue
    } else {
        return false
    }
}

func removeDuplicates(inout array: NSMutableArray) {
    let temp: NSMutableArray = NSMutableArray()
    for obj in array {
        if !temp.containsObject(obj) {
            temp.addObject(obj)
        }
    }
    array = temp
}

func isValidID(id: String) -> Bool {
    let lwr = id.lowercaseString
    func isInt(char: Character) -> Bool {
        for i in 0...9 {
            if String(char) == "\(i)" {
                return true
            }
        }
        return false
    }
    if lwr.characters.count != 4 {
        return false
    } else {
        for char: Character in lwr.characters {
            if !isInt(char) {
                if  char != "a" &&
                    char != "b" &&
                    char != "c" &&
                    char != "d" &&
                    char != "e" &&
                    char != "f" {
                        return false
                }
            }
        }
    }
    return true;
}

func genID() -> String {
    var id: String! = ""
    for _ in 0..<4 {
        let r = rand() % 16
        if r <= 9 {
            id.appendContentsOf("\(r)")
        } else {
            switch r {
            case 10: id.appendContentsOf("a")
            case 11: id.appendContentsOf("b")
            case 12: id.appendContentsOf("c")
            case 13: id.appendContentsOf("d")
            case 14: id.appendContentsOf("e")
            case 15: id.appendContentsOf("f")
            default: break
            }
        }
    }
    return id
}