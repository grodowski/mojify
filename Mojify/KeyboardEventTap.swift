//
//  KeyboardEventTap.swift
//  Mojify
//
//  Created by Jan Grodowski on 06/11/2016.
//  Copyright © 2016 Jan Grodowski. All rights reserved.
//
// capturing keys with sudo: http://stackoverflow.com/a/31898592/3526316
// posting key events: http://stackoverflow.com/a/25070476/3526316
//
// This proof of concept runs as root and captures system wide keyboard events.

import Foundation

class KeyboardEventTap {
    typealias Cb = (String) -> Void
    var callbacks = Array<Cb>()
    
    init() {
        guard let eventTap = createTap() else {
            // TODO(janek): use authorization services instead of requiring root access
            print("Failed to create event tap, do you have root access? 🔑❓")
            exit(1)
        }
        
        DispatchQueue.global(qos: .background).async {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            CFRunLoopRun()
        }
    }
    
    // Adds a callback function. Invoked by KeyboardEventTap every time a CGEvent is fired by the OS
    func registerAppCallback(closure: @escaping Cb) {
        callbacks.append(closure);
    }
    
    // Sends a faux-event, emulating a key press with desired key sequence. Emoji-ready!
    func dispatchEvent(chars: Array<UniChar>) {
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        guard let evt = CGEvent(keyboardEventSource: src, virtualKey: 0x52, keyDown: true) else { // 0
            print("Unable to initialize CGEvent")
            exit(1)
        }
        evt.keyboardSetUnicodeString(stringLength: 2, unicodeString: chars) // Override virtualKey
        evt.post(tap: CGEventTapLocation.cghidEventTap)
    }

    private func getAggregateCallback() -> CGEventTapCallBack {
        func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            print("Key event: ", event.getIntegerValueField(.keyboardEventKeycode))
            // TODO(janek): run all registered callbacks with key char
            return Unmanaged.passRetained(event)
        }
        return myCGEventCallback
    }
    
    private func createTap() -> CFMachPort? {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        return CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: getAggregateCallback(),
            userInfo: nil
        )
    }
}
