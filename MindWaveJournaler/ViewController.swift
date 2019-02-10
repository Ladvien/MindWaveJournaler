
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
    
    // Outlets
    @IBOutlet weak var mindWaveMobileConnection: UIView!
    @IBOutlet weak var recordingData: UIView!
    @IBOutlet weak var serverConnection: UIView!
    
    var connectionViews: [UIView] = []
    

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
        connectionViews = [mindWaveMobileConnection,
                           recordingData,
                           serverConnection]
        intitializeConnectionImages(views: connectionViews)
        
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
        mindWaveMobileConnection.changeSignal(color: .yellow)
        mindWaveDevice.connect(deviceID!)
    }
    
    func didConnect() {
        toast(text: "Connected")
        mindWaveMobileConnection.changeSignal(color: .green)
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
        recordingData.changeSignal(color: signalColor)
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
                    self.serverConnection.changeSignal(color: .red)
                    return
                }
                switch response.result {
                case .success:
                    self.serverConnection.changeSignal(color: .green)
                case .failure(let error):
                    print(error)
                }
        }

    }
    
    func toast(text: String) {
        self.view.makeToast(text, duration: 3.0, position: .center)
    }
    

    
    func intitializeConnectionImages(views: [UIView]) {
        for view in views {
            view.asCircle()
            view.backgroundColor = .red
        }
    }
    
    func mapPoorSignalToColor (signal: Int) -> UIColor {
        return UIColor.green.toColor(.red, percentage: CGFloat((Float(signal) / 200.0) * 100))
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
