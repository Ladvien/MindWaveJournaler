
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
import Toast_Swift
import Macaw

let central = CBCentralManager()

class ViewController: UIViewController, CBCentralManagerDelegate, MWMDelegate, MindMobileEEGSampleDelegate {

    @IBOutlet weak var mindWaveMobile: UIView!
    
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
        
        
        // Make Toaster_Swift Styl
        var style = ToastStyle()
        
        // this is just one of many style options
        style.backgroundColor = .blue
        ToastManager.shared.style = style
        
        let view = UIView()
        
        let form1 = Rect(x: 50.0, y: 50.0, w: 200.0, h: 200.0)
        let form2 = Circle(cx: 150.0, cy: 150.0, r: 100.0)
        
        let shape = Shape(form: form1, stroke: Stroke(width: 3.0))
        let animation = shape.formVar.animation(to: form2, during: 1.5, delay: 2.0)
        animation.autoreversed().cycle().play()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        
        UIView.animate(withDuration: 12.0, animations: { () -> Void in

        })
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
        
        Alamofire.request("http://maddatum.com:8080/eegsamples/", method: .post, parameters:  sample, encoding: JSONEncoding.default)
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
        self.view.makeToast(text, duration: 3.0, position: .center)
    }
    
    func changeImageColor(imageView: UIImageView, color: UIColor) {
//        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//            imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
//            imageView.tintColor = color
//        })
    }
    
}

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
