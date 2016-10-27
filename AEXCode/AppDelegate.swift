//
//  AppDelegate.swift
//  AEXCode
//
//  Created by Tomas Harkema on 13-10-16.
//  Copyright © 2016 Tomas Harkema. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApplication.shared().windows.forEach {
      $0.titleVisibility = .hidden
      $0.titlebarAppearsTransparent = true
      $0.backgroundColor = .blue
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

class MainWindow: NSWindow {
}
