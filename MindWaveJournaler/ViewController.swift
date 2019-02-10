
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

let central = CBCentralManager()

class ViewController: UIViewController, CBCentralManagerDelegate, MWMDelegate, MindMobileEEGSampleDelegate {
    
    // Server
    let server = "http://maddatum.com:8080/"
    let endPoint = "eegsamples/"
    
    // Colors
    let primary = UIColor(rgb: 0x00ACEA)
    let secondary = UIColor(rgb: 0xF4B844)
    let tertierary = UIColor(rgb: 0x00EFD1)
    let goodColor = UIColor(rgb: 0xABE188)
    let mediumColor = UIColor(rgb: 0xF4B844)
    let badColor = UIColor(rgb: 0xEE6352)
    
    // Outlets
    var connectionViews: [UIView] = []
    @IBOutlet weak var mindWaveMobileConnection: UIView!
    @IBOutlet weak var serverConnection: UIView!
    @IBOutlet weak var console: UITextView!
    
    var discoveredDevices: Array<String> = []
    
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
        
        // Attach delegates
        central.delegate = self
        mindWaveDevice.delegate = self
        sampleInProcess.delegate = self
        
        // Make Toaster_Swift Styl
        var style = ToastStyle()
        style.backgroundColor = .blue
        ToastManager.shared.style = style

        // Add graphical widgets to array for easy update
        connectionViews = [mindWaveMobileConnection, serverConnection]
        intitializeConnectionImages(views: connectionViews)
        
        // Start logging.
        console.text += "Searching for device...\n"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func deviceFound(_ devName: String!, mfgID: String!, deviceID: String!) {
        console.text += "Discovered device\n\t"
        console.text += "Device Name: " + devName! + "\n\t" + "Manfacturer ID: " + mfgID! + "\n\t" + "Device ID: " + deviceID! + "\n"
        mindWaveDevice.stopScanDevice()
        discoveredDevices.append(deviceID!)
        mindWaveDevice.readConfig()
        mindWaveMobileConnection.changeSignal(color: mediumColor)
        console.text += "Attempting to connect to " + devName!
        mindWaveDevice.connect(deviceID!)
    }
    
    func didConnect() {
        console.text += "Connection successful."
        mindWaveMobileConnection.changeSignal(color: goodColor)
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
        let signalColor = mapPoorSignalToColor(signal: Int(poorSignal))
        mindWaveMobileConnection.changeSignal(color: signalColor)
    }

    func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegPowerDelta", reading: [delta, theta, lowAlpha, highAlpha])
    }

    func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegPowerLowBeta", reading: [lowBeta, highBeta, lowGamma, midGamma])
    }
    
    func storeSample(sample: Parameters) {
        Alamofire.request(server + endPoint, method: .post, parameters:  sample, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                if let error = response.error?.localizedDescription {
                    self.toast(text: error)
                    self.serverConnection.changeSignal(color: self.badColor)
                    return
                }
                switch response.result {
                case .success:
                    self.serverConnection.changeSignal(color: self.goodColor)
                case .failure(let error):
                    print(error)
                }
        }

    }
    
    func toast(text: String) {
//        self.view.hideToast()
//        self.view.makeToast(text, duration: 3.0, position: .bottom)
    }
    
    func intitializeConnectionImages(views: [UIView]) {
        for view in views {
            view.asCircle()
            view.backgroundColor = badColor
        }
    }
    
    func mapPoorSignalToColor (signal: Int) -> UIColor {
        return goodColor.toColor(badColor, percentage: CGFloat((Float(signal) / 200.0) * 100))
    }
    
}

extension UIView {
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
    
    func changeSignal(color: UIColor) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.backgroundColor = color
            let scale = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.transform = scale
        }) { (Bool) in
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
}

extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            
            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
