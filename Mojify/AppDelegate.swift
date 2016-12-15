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
class AppDelegate: NSObject, NSApplicationDelegate, CocoaMQTTDelegate {

    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let tap = KeyboardEventTap()
    let mqtt: CocoaMQTT = CocoaMQTT(clientID: String(ProcessInfo.processInfo.processIdentifier), host: "m21.cloudmqtt.com", port: 18560)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "👻"
        statusItem.menu = statusMenu
        initMqtt()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    private func initMqtt() {
        // TODO(janek): security ;__;
        mqtt.username = "difrxdkm"
        mqtt.password = "EIAdmFlDJlos"
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout") // TODO(janek): what's this?
        mqtt.keepAlive = 60
        mqtt.delegate = self
        mqtt.connect()
    }
    
    private func initializeLayout() {
        var payload: String?
        if let path = Bundle.main.path(forResource: "sample_layouts_req", ofType: "json") {
            do {
                try payload = String(contentsOfFile: path)
            } catch _ {
                print("Cannot read file...")
                return
            }
        } else {
            print("Layout file does not exist")
            return
        }
        mqtt.publish(CocoaMQTTMessage(topic: "layouts", string: payload!))
    }
    
    // CocoaMQTT delegate impl
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("Connected")
    }
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("ConnectedAck")
        mqtt.subscribe("events")
        initializeLayout()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("👻 Subscribed")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        guard let msg = message.string else {
            print("Received empty message")
            return
        }
        print(msg)
        tap.dispatchEvent(chars: Array(msg.utf16))
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) { }
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) { }
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) { }
    func mqttDidPing(_ mqtt: CocoaMQTT) { }
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) { }
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) { }
    // CocoaMQTT delegate impl
}
