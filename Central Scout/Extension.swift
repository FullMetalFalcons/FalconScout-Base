//
//  Extension
//  Central Scout
//

import Cocoa
import CoreBluetooth

extension NSTextView {
    func appendText(text: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let attr = NSAttributedString(string: text)
            self.textStorage?.appendAttributedString(attr)
            self.scrollRangeToVisible(NSMakeRange(self.string!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), 0))
        })
    }
}


extension AppDelegate {
    /**
     Returns the current instance of the app
     */
    class func instance() -> AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        LOG("Terminating Scout... Goodbye")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    /**
     Reloads data for both tables
     */
    func reloadTableData() {
        let i = self.selectedIndex
        let col = self.selectedColumn
        self.tableAvailableDevices.reloadData()
        self.tableConnectedDevices.reloadData()
        if i != -1 {
            if col == 0 {
                self.tableAvailableDevices.selectRowIndexes(NSIndexSet(index: i), byExtendingSelection: false)
            } else if col == 1 {
                self.tableConnectedDevices.selectRowIndexes(NSIndexSet(index: i), byExtendingSelection: false)
            }
        }
    }
}

extension CBPeripheral {
    func isNotifyingCharacteristic() -> Bool {
        var n: [Bool] = [Bool]()
        if self.services == nil {
            LOG("Peripheral has no services")
            return false
        } else if self.services!.isEmpty {
            LOG("Peripheral services are empty")
            return false
        }
        for service in self.services! {
            if service.characteristics == nil {
                LOG("Peripheral has no characteristics")
                return false
            } else if service.characteristics!.isEmpty {
                LOG("Peripheral characteristics are empty")
                return false
            }
            for char in service.characteristics! {
                n.append(char.isNotifying)
            }
        }
        if !n.contains(true) {
            LOG("Peripheral is NOT notifying")
            return false
        } else {
            LOG("Peripheral IS notifying")
            return true
        }

    }
}

/*
- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees {
NSSize rotatedSize = NSMakeSize(self.size.height, self.size.width) ;
NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedSize] ;

NSAffineTransform* transform = [NSAffineTransform transform] ;

// In order to avoid clipping the image, translate
// the coordinate system to its center
[transform translateXBy:+self.size.width/2
yBy:+self.size.height/2] ;
// then rotate
[transform rotateByDegrees:degrees] ;
// Then translate the origin system back to
// the bottom left
[transform translateXBy:-rotatedSize.width/2
yBy:-rotatedSize.height/2] ;

[rotatedImage lockFocus] ;
[transform concat] ;
[self drawAtPoint:NSMakePoint(0,0)
fromRect:NSZeroRect
operation:NSCompositeCopy
fraction:1.0] ;
[rotatedImage unlockFocus] ;

return [rotatedImage autorelease] ;
}
*/

extension NSImage {
    func rotateByDegrees(degrees: CGFloat) -> NSImage {
        let rotatedSize = NSSize(width: self.size.width, height: self.size.height)
        let rotatedImage = NSImage(size: rotatedSize)
        let transform = NSAffineTransform()
        transform.translateXBy(self.size.width / 2, yBy: self.size.height / 2)
        transform.rotateByDegrees(degrees)
        transform.translateXBy(-rotatedSize.width / 2, yBy: -rotatedSize.height / 2)
        rotatedImage.lockFocus()
        transform.concat()
        self.drawAtPoint(NSPoint(x: 0, y: 0), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)
        rotatedImage.unlockFocus()
        return rotatedImage
    }
}