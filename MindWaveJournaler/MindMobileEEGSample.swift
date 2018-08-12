//
//  MindMobileEEGSample.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 8/11/18.
//  Copyright © 2018 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import Alamofire

public protocol MindMobileEEGSampleDelegate {
    func completedSample(sample: Parameters)
}

public class MindMobileEEGSample: NSObject {
    
    public var delegate: MindMobileEEGSampleDelegate?
    
    private var time = ""
    
    private var theta: Int32 = -1
    private var delta: Int32 = -1
    private var lowAlpha: Int32 = -1
    private var highAlpha: Int32 = -1
    private var lowBeta: Int32 = -1
    private var highBeta: Int32 = -1
    private var lowGamma: Int32 = -1
    private var midGamma: Int32 = -1
    private var attention: Int32 = -1
    private var meditation: Int32 = -1
    private var blink: Int32 = -1
    private var poorSignal: Int32 = -1
    
    override init() {
        super.init()
        startNewSample()
    }
    
    public func startNewSample() {
        theta = -1
        delta = -1
        lowAlpha = -1
        highAlpha = -1
        lowBeta = -1
        highBeta = -1
        lowGamma = -1
        midGamma = -1
        attention = -1
        meditation = -1
        blink = -1
        poorSignal = -1
        time = timeToString()
    }
    
    public func addDataToSampe(packetName: String, reading: Array<Int32>) -> Void {
        switch packetName {
        case "eegBlink":
            blink = reading[0]
            // Blink does not update delegate, as the TGM module
            // only updates if a blink is suspected.
            break
        case "eSense":
            poorSignal = reading[0]
            attention = reading[1]
            meditation = reading[2]
            updateDelegate()
            break
        case "eegPowerDelta":
            delta = reading[0]
            theta = reading[1]
            lowAlpha = reading[2]
            highAlpha = reading[3]
            updateDelegate()
            break
        case "eegPowerLowBeta":
            lowBeta = reading[0]
            highBeta = reading[1]
            lowGamma = reading[2]
            midGamma = reading[3]
            updateDelegate()
            break
        default:
            print("error")
        }
    }
    
    private func updateDelegate() {
        if(completePacket()) {
            let parameters = getSampleHTTPParameter()
            delegate?.completedSample(sample: parameters)
        }
    }
    
    private func completePacket() -> Bool {
        
        // blink is not checked, as it only updates when
        // on occurrence.
        
        if(theta        < 0 ||
            delta       < 0 ||
            lowAlpha    < 0 ||
            highAlpha   < 0 ||
            lowBeta     < 0 ||
            highBeta    < 0 ||
            lowGamma    < 0 ||
            midGamma    < 0 ||
            attention   < 0 ||
            meditation  < 0 ||
            poorSignal  < 0 ||
            time        == "") {
            return false
        }
        return true
    }
    
    private func getSampleHTTPParameter() -> Parameters {
        let parameters: Parameters =  [
            "time": time,
            "theta": theta,
            "lowAlpha": lowAlpha,
            "highAlpha": highAlpha,
            "lowBeta": lowBeta,
            "highBeta": highBeta,
            "lowGamma": lowGamma,
            "midGamma": midGamma,
            "attention": attention,
            "meditation": meditation,
            "blink": blink,
            "poorSignal": poorSignal
        ]
        return parameters
    }
    
    private func timeToString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone.init(secondsFromGMT: -18000)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let result = formatter.string(from: date)
        return result
    }
}
