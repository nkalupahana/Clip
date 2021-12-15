//
//  AppDelegate.swift
//  Clip
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var clipper: Clipper!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create actual clipper object
        self.clipper = Clipper()
        
        // Create popover with ContentView UI
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 200, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Register status bar icon
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.action = #selector(act(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // Run whenever menu bar icon is clicked
    @objc func act(_ sender: AnyObject?) {
        // Event performed on menu bar icon
        let event = NSApp.currentEvent!
        
        // On right click, toggler popover
        // Otherwise, make a clip
        if event.type == NSEvent.EventType.rightMouseUp {
            if let button = self.statusBarItem.button {
                if self.popover.isShown {
                    self.popover.performClose(sender)
                } else {
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                    self.popover.contentViewController?.view.window?.makeKey()
                }
            }
        } else {
            self.clipper.clip()
        }
    }
}
