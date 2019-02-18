//
//  ActivityCollectionViewController.swift
//  MindWaveJournaler
//
//  Created by C. Thomas Brittain on 2/10/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ActivityCollectionViewController: UICollectionViewController, RemoteDevicesDelegate, UIGestureRecognizerDelegate {
    
    // Get user settings wrapper
    var activitiesSettings = ActivitiesSettings()
    var activities: [String:String] = [:]
    
    let colors = [primary, secondary, tertierary, goodColor, mediumColor, badColor]
    
    @IBOutlet var activitiesCollectionView: UICollectionView!
    
    func update(deviceConnection: DeviceConnection, serverConnection: ServerConnection, deviceSignalStrength: Double, log: String) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 40) / 2
        let layout = activitiesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Long-press registration
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.3
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activitiesSettings = ActivitiesSettings()
        activities = activitiesSettings.getActivities()
        activitiesCollectionView.reloadData()
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        // If the Long-Press Gesture Started
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            // Get point then indexPath of the item prssed.
            let p = gestureRecognizer.location(in: self.collectionView)
            let indexPath : IndexPath = (self.collectionView?.indexPathForItem(at: p))! as IndexPath

            // Get Activity
            let activityName = Array(activities.keys)[indexPath.row]
            let refreshAlert = UIAlertController(title: "Delete Activity", message: "Delete this activity?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.activitiesSettings.deleteActivity(key: activityName)
                self.activitiesSettings = ActivitiesSettings()
                self.activities = self.activitiesSettings.getActivities()
                self.activitiesCollectionView.reloadData()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("not deleted")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            return
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return activities.keys.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let activityNames = Array(activities.keys)
        print(activityNames)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath)
        if let label = cell.viewWithTag(100) as? UILabel {
            label.text = activityNames[indexPath.row]
        }
        if let imageView = cell.viewWithTag(200) as? UIImageView {
            if let imageName = activities[activityNames[indexPath.row]] {
                if let image = UIImage(named: imageName) {
                    imageView.image = image
                    imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = UIColor.green
                }
            }
        }
        let randNum = Int.random(in: 0...colors.count - 1)
        cell.backgroundColor = colors[randNum]
        
        
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //  Check if Add button, otherwise set Selected Action.
        print(indexPath.row)
        print(activities)
        let activityName = Array(activities.keys)[indexPath.row].lowercased()
        switch activityName {
            case "add":
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "createActivity") as! CreateActivityViewController
                self.navigationController?.pushViewController(nextViewController, animated: true)
                break
            default:
                remoteDevices.setActivity(activity: activityName)
                break
            }
    }
}
