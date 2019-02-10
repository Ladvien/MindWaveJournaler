//
//  Connections.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 2/10/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import Alamofire

let central = CBCentralManager()

public enum ServerConnection {
    case unknown
    case failedToContact
    case connected
}

public enum DeviceConnection {
    case unknown
    case bluetoothOff
    case bluetoothOn
    case searching
    case connecting
    case connected
    case lostConnection
}

public protocol RemoteDevicesDelegate {
    func update(deviceConnection: DeviceConnection, serverConnection: ServerConnection, deviceSignalStrength: Double, log: String)
}

public class RemoteDevices: NSObject, CBCentralManagerDelegate, MWMDelegate, MindMobileEEGSampleDelegate {
    
    public var delegate: RemoteDevicesDelegate?
    private var mindWaveDevice = MWMDevice()
    private var sampleInProcess = MindMobileEEGSample()
    
    // Constants
    let server = "http://maddatum.com:8080/"
    let endPoint = "eegsamples/"
    
    // Private properties
    private var logText = ""
    private var mindMobileSignalStrength = 0.0
    private var connectedDeviceId = ""
    private var connectedDeviceName = ""
    private var targetConnectionDeviceId = ""
    private var targetConnectionDeviceName = ""
    private var serverConnection: ServerConnection = .unknown
    private var deviceConnection: DeviceConnection = .unknown
    
    override init() {
        super.init()
        central.delegate = self
        mindWaveDevice.delegate = self
        sampleInProcess.delegate = self
        serverConnection = .unknown
        deviceConnection = .unknown
    }
    

    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            mindWaveDevice.scanDevice()
            deviceConnection = .searching
        default:
            addTextToConsole(text: "Bluetooth is turned off.\n")
            deviceConnection = .bluetoothOff
        }
        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
    }
    
    public func completedSample(sample: Parameters) {
        storeSample(sample: sample)
        sampleInProcess.startNewSample()
        addTextToConsole(text: "Completed sample.\n")
        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
    }
    
    public func didDisconnect() {
        deviceConnection = .lostConnection
        addTextToConsole(text: "Disconnected from MindWave Mobile\n")
        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
        
        deviceConnection = .searching
        mindWaveDevice.scanDevice()
        addTextToConsole(text: "Searching for device...\n")
        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
    }
    
    public func deviceFound(_ devName: String!, mfgID: String!, deviceID: String!) {
        // Found a device, let the user know.
        addTextToConsole(text: "Discovered device\n\t")
        addTextToConsole(text: "Device Name: " + devName! + "\n\t" + "Manfacturer ID: " + mfgID! + "\n\t" + "Device ID: " + deviceID! + "\n")
        
        // Stop searching and remember device ID.
        mindWaveDevice.stopScanDevice()
        
        // Get the configuration information from the Mind Wave Mobile.
        mindWaveDevice.readConfig()
        
        // Update the user about what's going on.        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
        addTextToConsole(text: "Attempting to connect to " + devName! + "\n")
        
        // Attempt to connect to the discovered device.
        deviceConnection = .connecting
        mindWaveDevice.connect(deviceID!)
        targetConnectionDeviceId = deviceID!
        targetConnectionDeviceId = devName
        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
    }
    
    public func didConnect() {
        deviceConnection = .connected
        addTextToConsole(text: "Connection successful.\n")
        targetConnectionDeviceId = ""
        targetConnectionDeviceId = ""
        delegate?.update(deviceConnection: deviceConnection, serverConnection: serverConnection, deviceSignalStrength: mindMobileSignalStrength, log: logText)
    }
    
    private func eegBlink(_ blinkValue: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegBlink", reading: [blinkValue])
    }
    
    private func eegSample(_ sample: Int32) {
        // Not currently used
    }
    
    private func eSense(_ poorSignal: Int32, attention: Int32, meditation: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eSense", reading: [poorSignal, attention, meditation])
    }
    
    private func eegPowerDelta(_ delta: Int32, theta: Int32, lowAlpha: Int32, highAlpha: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegPowerDelta", reading: [delta, theta, lowAlpha, highAlpha])
    }
    
    private func eegPowerLowBeta(_ lowBeta: Int32, highBeta: Int32, lowGamma: Int32, midGamma: Int32) {
        sampleInProcess.addDataToSampe(packetName: "eegPowerLowBeta", reading: [lowBeta, highBeta, lowGamma, midGamma])
    }
    
    private func addTextToConsole(text: String) {
        logText += text
    }
    
    func storeSample(sample: Parameters) {
        Alamofire.request(server + endPoint, method: .post, parameters:  sample, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                if let error = response.error?.localizedDescription {
                    self.addTextToConsole(text: "Unable to make contact with Mind Journal Server: \n\t")
                    self.addTextToConsole(text: "Server address: " + self.server + "\n\t")
                    self.addTextToConsole(text: "End point: " + self.endPoint + "\n")
                    self.serverConnection = .failedToContact
                    self.delegate?.update(deviceConnection: self.deviceConnection, serverConnection: self.serverConnection, deviceSignalStrength: self.mindMobileSignalStrength, log: self.logText)
                    return
                }
                switch response.result {
                case .success:
                    self.addTextToConsole(text: "Connected to server: \n\t")
                    self.addTextToConsole(text: self.server + self.endPoint + "\n\t")
                    self.serverConnection = .connected
                    self.delegate?.update(deviceConnection: self.deviceConnection, serverConnection: self.serverConnection, deviceSignalStrength: self.mindMobileSignalStrength, log: self.logText)
                case .failure(_):
                    print("Error")
                }
        }
    }
    
    
}
