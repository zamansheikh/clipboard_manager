import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}


// import Cocoa
// import FlutterMacOS

// @main
// class AppDelegate: FlutterAppDelegate {
//   var statusBarItem: NSStatusItem!
//   var window: NSWindow?

//   override func applicationDidFinishLaunching(_ notification: Notification) {
//     let flutterViewController = FlutterViewController()
//     let window = NSWindow(
//       contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
//       styleMask: [.borderless],
//       backing: .buffered,
//       defer: false
//     )
//     window.center()
//     window.contentViewController = flutterViewController
//     window.isOpaque = false
//     window.backgroundColor = .clear
//     window.setIsVisible(false)
//     self.window = window

//     statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//     if let button = statusBarItem.button {
//       button.title = "Clipboard"
//       button.action = #selector(toggleWindow(_:))
//       button.target = self
//     }

//     RegisterGeneratedPlugins(registry: flutterViewController)
//     super.applicationDidFinishLaunching(notification)
//   }

//   @objc func toggleWindow(_ sender: Any?) {
//     if let window = window {
//       if window.isVisible {
//         window.orderOut(sender)
//       } else {
//         window.makeKeyAndOrderFront(sender)
//         NSApp.activate(ignoringOtherApps: true)
//       }
//     }
//   }

//   override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//     return false
//   }

//   override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
//     return true
//   }
// }


