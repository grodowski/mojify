//
//  AppDelegate.swift
//  Mojify
//
//  Created by Jan Grodowski on 15/12/2016.
//  Copyright © 2016 Jan Grodowski. All rights reserved.
//

import Cocoa
import CocoaMQTT

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let tap = KeyboardEventTap.init()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "👻"
        statusItem.menu = statusMenu
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
}
