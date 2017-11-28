//
//  ViewController.swift
//  MacToIos
//
//  Created by sycf_ios on 2017/11/27.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreMediaIO

class ViewController: NSViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var previewView: NSView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var session: AVCaptureSession!
    var movieOutput: AVCaptureMovieFileOutput!
    var stillImageOutput: AVCaptureStillImageOutput!
    var input: AVCaptureDeviceInput!
    var saveFilesInPath: String!
    var file: NSURL!
    override func viewDidLoad() {
        super.viewDidLoad()
//        _ = AVCaptureDevice.devices()
        session = AVCaptureSession()
        movieOutput = AVCaptureMovieFileOutput()
        
        saveFilesInPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first
        var saveFileUrl = URL(fileURLWithPath: saveFilesInPath)
        saveFileUrl = saveFileUrl.appendingPathComponent("IOSTool")
        saveFilesInPath = saveFileUrl.path
        makeDevicesVisible()
//        NotificationCenter.default.addObserver(self, selector: #selector(deviceWasConnected(noti:)), name: .AVCaptureDeviceWasConnected, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(deviceWasDisconnected(noti:)), name: .AVCaptureDeviceWasDisconnected, object: nil)
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: OperationQueue.main) { (note) in
            self.deviceWasConnected(noti: note)
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: OperationQueue.main) { (note) in
            self.deviceWasDisconnected(noti: note)
        }
        
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: OperationQueue.main) { (note) in
            NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceWasConnected, object: nil)
            NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceWasDisconnected, object: nil)
        }
        let filePath = self.generateFilePath(prefix: "iOS-recording-", type: "mov")
        self.file = URL(fileURLWithPath: filePath) as NSURL
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        _ = AVCaptureDevice.devices()
        for foundDevice in AVCaptureDevice.devices() {
            if foundDevice.modelID == "iOS Device" {
               
            }
        }
    }
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceWasConnected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceWasDisconnected, object: nil)
    }
    func setup(device: AVCaptureDevice) {
       _ = AVCaptureDevice.devices()
//        makeDevicesVisible()
        
//        var err: Error? = nil
        self.session.beginConfiguration()
        input = try! AVCaptureDeviceInput(device: device)
        session.addOutput(movieOutput)
        session.addInput(input)
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = self.previewView.bounds
        self.previewView.layer?.addSublayer(previewLayer)
        self.session.commitConfiguration()
        session.startRunning()
    }
    @objc func deviceWasConnected(noti: Notification) {
        print("deviceWasConnected")
        for foundDevice in AVCaptureDevice.devices() {
            if foundDevice.modelID == "iOS Device" {
                let device = foundDevice
                let deviceName = device.localizedName
                let uuid = device.uniqueID
                print(" deviceName: \(deviceName) \n uuid: \(uuid)")
                setup(device: device)
            }
        }
        
    }
    @IBAction func handleClick(_ sender: NSButton) {
        
        if !movieOutput.isRecording {
            
            self.movieOutput.startRecording(to: self.file as URL, recordingDelegate: self)
            
            
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                self.movieOutput.stopRecording()
                self.file = nil
            })
        }
    }
    func generateFilePath(prefix: String, type: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd-HHmmSS"
        let dateStamp = formatter.string(from: Date())
        let filename = "\(prefix)\(dateStamp).\(type)"
        let fileUrl = URL(fileURLWithPath: saveFilesInPath).appendingPathComponent(filename)
        let filePath = fileUrl.path
        return filePath
    }
    @objc func deviceWasDisconnected(noti: Notification) {
        print("deviceWasDisconnected")
    }
    //使设备可见
    func makeDevicesVisible() {
        print("making visible")
        var prop = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
                                             mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
                                             mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        var allow: UInt32 = 1
        let dataSize: UInt32 = 4
        let zero: UInt32 = 0
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop, zero, nil, dataSize, &allow)
        
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        print("recording did start")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            print("----- recording did end")
        }else {
            print("Recording ended in error")
        }
    }
    
}

