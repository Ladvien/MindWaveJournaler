//
//  Connections.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 2/10/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import Foundation
import UIKit

public class RemoteDevices {
    
    // Private properties
    private var consoleText = ""
    private var mindMobileSignalStrength = 0.0
    private var connectedDeviceId = ""
    private var connectedDeviceName = ""
    
    // Public properties
    public var connectedToServer = false
    public var connectedToDevice = false
    
    //
    private var console: UITextView?
    
    init() {
        
    }
    
    public func setConsole(console: UITextView) {
        self.console = console
    }
    
    public func addTextToConsole(text: String) {
        consoleText += text
        if let console = console {
            console.text = consoleText
        }
    }
    
    
}
