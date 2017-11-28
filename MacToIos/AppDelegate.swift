//
//  AppDelegate.swift
//  MacToIos
//
//  Created by sycf_ios on 2017/11/27.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

import Cocoa
import AVFoundation
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        _ = AVCaptureDevice.devices()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

