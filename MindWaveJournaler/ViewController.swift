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
//        mindWaveDevice.delegate!.mwmBaudRate!(1, notchFilter: 0)
//        mindWaveDevice.enableConsoleLog(true)
        mindWaveDevice.readConfig()
    }
    
    func didConnect() {
        print("Connected")
        
        let parameters: Parameters =  [
            "time": 4,
            "theta": 55,
            "lowAlpha": 2,
            "highAlpha": 3,
            "lowBeta": 4,
            "highBeta": 5,
            "lowGamma": 6,
            "highGamma": 7,
            "attention": 8,
            "meditation": 9,
            "blink": 55
        ]
        
        
        Alamofire.request("http://ladvien.com:3000/eegsamples/", method: .post, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in
                print(response)
//            print("Request: \(String(describing: response.request!))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
        }
    }
    
    func didDisconnect() {
        mindWaveDevice.scanDevice()
    }
//
//    func eegBlink(_ blinkValue: Int32) {
////        print(blinkValue)
//    }
//
//    func eegSample(_ sample: Int32) {
////        print(sample)
//    }
//
//    func eSense(_ poorSignal: Int32, attention: Int32, meditation: Int32) {
////        print(attention)
//    }
//
////    func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32) {
////        print("Delta:      " + String(delta) + "\n",
////              "Theta:      " + String(theta) + "\n",
////              "Low Alpha:  " + String(lowAlpha) + "\n",
////              "High Alpha: " + String(highAlpha) + "\n"
////        )
////    }
////
////    func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
////        print("Low Beta:   " + String(lowBeta) + "\n",
////              "High Beta:  " + String(highBeta) + "\n",
////              "Low Gamma:  " + String(lowGamma) + "\n",
////              "Mid Gamma:  " + String(midGamma) + "\n"
////        )
////    }
//
//    func mwmBaudRate(_ baudRate: Int32, notchFilter: Int32) {
//        print(baudRate)
//        print(notchFilter)
//    }

}

