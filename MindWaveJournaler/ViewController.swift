//
//  ViewController.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 8/3/18.
//  Copyright © 2018 Honeysuckle Hardware. All rights reserved.
//

import UIKit
import CoreBluetooth

let central = CBCentralManager()

class ViewController: UIViewController, CBCentralManagerDelegate, MWMDelegate {

    let mindWaveDevice = MWMDevice()
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            mindWaveDevice.scanDevice()
        default:
            print("BLE Off")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        central.delegate = self
        mindWaveDevice.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func deviceFound(_ devName: String!, mfgID: String!, deviceID: String!) {
        print("Device Name" + devName! + "\n" + "Manfacturer ID: " + mfgID! + "\n" + "Device ID: " + deviceID!)
        mindWaveDevice.stopScanDevice()
        mindWaveDevice.connect(deviceID!)
//        mindWaveDevice.mwmBaudRate(1, notchFilter: 0)
        mindWaveDevice.delegate!.mwmBaudRate!(1, notchFilter: 0)
//        mindWaveDevice.enableConsoleLog(true)
        mindWaveDevice.readConfig()
    }
    
    func didConnect() {
        print("Connected")
    }
    
    func didDisconnect() {
        mindWaveDevice.scanDevice()
    }
    
    func eegBlink(_ blinkValue: Int32) {
//        print(blinkValue)
    }
    
    func eegSample(_ sample: Int32) {
//        print(sample)
    }
    
    func eSense(_ poorSignal: Int32, attention: Int32, meditation: Int32) {
//        print(attention)
    }

//    func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32) {
//        print("Delta:      " + String(delta) + "\n",
//              "Theta:      " + String(theta) + "\n",
//              "Low Alpha:  " + String(lowAlpha) + "\n",
//              "High Alpha: " + String(highAlpha) + "\n"
//        )
//    }
//
//    func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
//        print("Low Beta:   " + String(lowBeta) + "\n",
//              "High Beta:  " + String(highBeta) + "\n",
//              "Low Gamma:  " + String(lowGamma) + "\n",
//              "Mid Gamma:  " + String(midGamma) + "\n"
//        )
//    }

    func mwmBaudRate(_ baudRate: Int32, notchFilter: Int32) {
        print(baudRate)
        print(notchFilter)
    }

}

