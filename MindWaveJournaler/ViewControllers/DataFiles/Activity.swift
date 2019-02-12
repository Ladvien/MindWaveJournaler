//
//  Activity.swift
//  Alamofire
//
//  Created by Casey Brittain on 2/11/19.
//

import Foundation

class Activity {
    // Attributes
    public private(set) var label: String
    public private(set) var imageName: String
    
    init(activityLabel: String, activityImageName: String) {
        label = activityLabel
        imageName = activityImageName
    }
}
