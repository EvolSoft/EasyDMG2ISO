//
//  AppDelegate.swift
//  DMG2ISO
//
//  Created by Flavius12 on 09/11/2020.
//  Copyright © 2020 EvolSoft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    //Reopen window when clicking on app icon
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if(!flag){
            window.makeKeyAndOrderFront(self);
            return true;
        }
        return false;
    }

}

