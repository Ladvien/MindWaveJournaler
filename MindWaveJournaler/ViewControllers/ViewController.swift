
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

let remoteDevices = RemoteDevices()

class ViewController: UIViewController, RemoteDevicesDelegate {
    
    // Colors
    let primary = UIColor(rgb: 0x00ACEA)
    let secondary = UIColor(rgb: 0xF4B844)
    let tertierary = UIColor(rgb: 0x00EFD1)
    let goodColor = UIColor(rgb: 0xABE188)
    let mediumColor = UIColor(rgb: 0xF4B844)
    let badColor = UIColor(rgb: 0xEE6352)

    // Flags
    var segueUnderway = false

    
    // Outlets
    var connectionViews: [UIView] = []
    @IBOutlet weak var mindWaveMobileConnectionIndicator: UIView!
    @IBOutlet weak var serverConnectionIndicator: UIView!
    @IBOutlet weak var console: UITextView!
    
    // Buttons
    @IBOutlet weak var activity: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix for automatic scrolling on UITextView
        console.layoutManager.allowsNonContiguousLayout = false
        
        // Add graphical widgets to array for easy update
        connectionViews = [mindWaveMobileConnectionIndicator, serverConnectionIndicator]
        intitializeConnectionImages(views: connectionViews)
        
        // Start logging.
        console.textColor = primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        remoteDevices.delegate = self
        if remoteDevices.serverConnection == .connected {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func moveToActivityView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "activity")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func intitializeConnectionImages(views: [UIView]) {
        for view in views {
            view.asCircle()
            view.backgroundColor = badColor
        }
    }
    
    func update(deviceConnection: DeviceConnection, serverConnection: ServerConnection, deviceSignalStrength: Double, log: String) {
        
        // Update user's log
        console.text = log
        let stringLength:Int = console.text.count
        console.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
        
        // Update device signal icons.
        switch deviceConnection {
        case .connecting:
            mindWaveMobileConnectionIndicator.changeSignal(color: mediumColor)
        case .connected:
            mindWaveMobileConnectionIndicator.changeSignal(color: goodColor)
        default:
            mindWaveMobileConnectionIndicator.changeSignal(color: badColor)
        }
        
        // Update device signal icons.
        switch deviceConnection {
        case .connecting:
            mindWaveMobileConnectionIndicator.changeSignal(color: mediumColor)
        case .connected:
            mindWaveMobileConnectionIndicator.changeSignal(color: goodColor)
        default:
            mindWaveMobileConnectionIndicator.changeSignal(color: badColor)
        }
        
        // Update server signal icons.
        switch serverConnection {
        case .connected:
            serverConnectionIndicator.changeSignal(color: goodColor)
            if !segueUnderway {
                segueUnderway = true
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "activity") as! ActivityViewController
                    remoteDevices.delegate = nextViewController
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
        default:
            serverConnectionIndicator.changeSignal(color: badColor)
        }
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
