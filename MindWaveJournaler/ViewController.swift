
// To interact with Node server.
// https://stackoverflow.com/questions/32631184/the-resource-could-not-be-loaded-because-the-app-transport-security-policy-requi

//
//  ViewController.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 8/3/18.
//  Copyright © 2018 Honeysuckle Hardware. All rights reserved.
//


import UIKit
import CoreBluetooth
import Alamofire
import Toaster

let central = CBCentralManager()

class ViewController: UIViewController, CBCentralManagerDelegate, MWMDelegate, MindMobileEEGSampleDelegate {
    
    var discoveredDevices: Array<String> = []
    
    @IBAction func startButton(_ sender: Any) {
        mindWaveDevice.connect(discoveredDevices[0])
    }
    
    func completedSample(sample: Parameters) {
        storeSample(sample: sample)
        sampleInProcess.startNewSample()
    }
    
    let mindWaveDevice = MWMDevice()
    let sampleInProcess = MindMobileEEGSample()
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            mindWaveDevice.scanDevice()
        default:
            toast(text: "Bluetooth is turned off.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        central.delegate = self
        mindWaveDevice.delegate = self
        sampleInProcess.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func deviceFound(_ devName: String!, mfgID: String!, deviceID: String!) {
        print("Device Name" + devName! + "\n" + "Manfacturer ID: " + mfgID! + "\n" + "Device ID: " + deviceID!)
        mindWaveDevice.stopScanDevice()
        discoveredDevices.append(deviceID!)
        toast(text: "Discovered device.")
        mindWaveDevice.readConfig()
    }
    
    func didConnect() {
        toast(text: "Connected")
    }
    
    func didDisconnect() {
        mindWaveDevice.scanDevice()
        toast(text: "Disconnected.  Trying to reconnect...")
    }

    func eegBlink(_ blinkValue: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegBlink", reading: [blinkValue])
    }

    func eegSample(_ sample: Int32) {
        // Not currently used
    }

    func eSense(_ poorSignal: Int32, attention: Int32, meditation: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eSense", reading: [poorSignal, attention, meditation])
    }

    func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegPowerDelta", reading: [delta, theta, lowAlpha, highAlpha])
    }

    func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegPowerLowBeta", reading: [lowBeta, highBeta, lowGamma, midGamma])
    }
    
    func storeSample(sample: Parameters) {
        
        Alamofire.request("http://ladvien.com:3000/eegsamples/", method: .post, parameters:  sample, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                if let error = response.error?.localizedDescription {
                    self.toast(text: error)
                    return
                }
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                }
        }

    }
    
    func toast(text: String) {
        let toasterFont = UIFont.systemFont(ofSize: 24.0)
        ToastView.appearance().font = toasterFont
        let toast = Toast(text: text, delay: Delay.short, duration: Delay.long)
        toast.show()
    }
    
}

