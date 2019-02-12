//
//  UserSettings.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 2/11/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import Foundation

public class UserSettings: NSObject {
    
    // Keys
    private let activityDictKey = "activityDict"
    
    // Privates
    private let userSettings = UserDefaults.standard
    private let activities: [String:String]?
    
    public override init() {
        if let savedArray = userSettings.object(forKey: activityDictKey) as? [String:String] {
            activities = savedArray
        } else {
            activities = ["Add": "activity_325"]
            userSettings.set(activities, forKey: activityDictKey)
        }
    }
    
    
    public func getListOfActivityNames() -> [String] {
        if let activities = activities {
            return Array(activities.keys)
        }
        return []
    }
    
    public func addActivityImage(label: String, imageName: String) {
        if var activities = activities {
            activities[label] = imageName
            userSettings.set(label, forKey: imageName)
        }
    }
    
    public func getImageName(activityName: String) -> String {
        if let activityImageName = activities?[activityName] {
            return activityImageName
        }
        return ""
    }
    
    private func saveSetting(key: String, value: String) {
        userSettings.set(value, forKey: key)
    }
    
    private func getSetting(key: String) -> String {
        if let setting = userSettings.string(forKey: key) {
            return setting
        }
        return ""
    }
    
    private func deleteSetting(key: String) -> Bool {
        // Attempt to remove object
        userSettings.removeObject(forKey: key)
        if let _ = userSettings.string(forKey: key) {
            // Return false if it still exists.
            return false
        }
        return true
    }
    
    public func saveActivity(labelName: String, imageName: String) -> Bool {
        
        return false
    }
    
}
