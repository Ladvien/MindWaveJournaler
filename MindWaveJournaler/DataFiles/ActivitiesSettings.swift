//
//  UserSettings.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 2/11/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import Foundation

public class ActivitiesSettings: NSObject {
    
    // Keys
    private let activityDictKey = "activityDict"
    
    // Privates
    private let userSettings = UserDefaults.standard
    private var activities: [String:String] = [:]
    
    public override init() {
        if let savedArray = userSettings.object(forKey: activityDictKey) as? [String:String] {
            activities = savedArray
        } else {
            activities = ["Add": "activity_325"]
            userSettings.set(activities, forKey: activityDictKey)
        }
    }
    
    public func getActivities() -> [String:String] {
        return activities
    }
    
    public func deleteActivity(key: String) {
        activities.removeValue(forKey: key)
        userSettings.set(activities, forKey: activityDictKey)
    }
    
    public func saveActivity(labelName: String, imageName: String) {
        activities[labelName] = imageName
        userSettings.set(activities, forKey: activityDictKey)
    }
    
    
}
