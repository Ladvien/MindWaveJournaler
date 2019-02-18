//
//  CreateActivityViewController.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 2/16/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import UIKit

class CreateActivityViewController: UIViewController, UITextFieldDelegate {
    
    let activity = Activity()
    var activitiesSettings = ActivitiesSettings()
    @IBAction func create(_ sender: Any) {
        activitiesSettings.saveActivity(labelName: activity.label, imageName: activity.imageName)
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var activityLabel: UITextField!
    @IBOutlet weak var activityImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure the keyboard return is setup.
        activityLabel.delegate = self
        activityLabel.addTarget(
            nil,
            action: #selector(CreateActivityViewController.labeTextChanged(_:)),
            for: UIControlEvents.editingChanged
        )
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set Activity defaults.
        activityLabel.placeholder = "Activity Name"
        if activity.imageName == "" {
            activity.imageName = "activity_326"
        }
        if let image = UIImage(named: activity.imageName){
            activityImage.setBackgroundImage(image, for: .normal)
        }
    }
    
    @objc func labeTextChanged(_ textField: UITextField) {
        if let activityLabel = activityLabel.text {
            activity.label = activityLabel
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Make sure the return hides the keyboard.
        endEditingActivityLabel()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingActivityLabel()
    }
    
    func endEditingActivityLabel() {
        activityLabel.resignFirstResponder()
        
        if let activityLabel = activityLabel.text {
            let validLabel = makeValidLabel(label: activityLabel)
            activity.label = validLabel
        } else {
            activity.label = "Unnamed Activity"
        }
        
        activityLabel.text = activity.label
    }
    
    func makeValidLabel(label: String) -> String {
        let activityLabelCandidate = label.replacingOccurrences(of: " ", with: "").lowercased()
        if activityLabelCandidate == "activity name" ||
            activityLabelCandidate == "" {
            return "Unnamed Activity"
        }
        return label
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let iconSelectViewController = segue.destination as? IconSelectCollectionViewController {
            iconSelectViewController.activity = self.activity
        }
    }
}
