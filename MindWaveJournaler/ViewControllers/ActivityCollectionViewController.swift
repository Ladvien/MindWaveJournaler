//
//  ActivityCollectionViewController.swift
//  MindWaveJournaler
//
//  Created by C. Thomas Brittain on 2/10/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ActivityCollectionViewController: UICollectionViewController, RemoteDevicesDelegate {
    
    var collectionLabels = ["Add Activity", "Else", "Something"]
    var collectionImages = [UIImage()]
    
    @IBOutlet var activitiesCollectionView: UICollectionView!
    
    func update(deviceConnection: DeviceConnection, serverConnection: ServerConnection, deviceSignalStrength: Double, log: String) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = (view.frame.size.width - 40) / 2
        let layout = activitiesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.

        for i in 0...300 {
            if let image = UIImage(named: "activity_" + String(i)) {
                collectionImages.append(image)
            }
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return collectionLabels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath)
        if let label = cell.viewWithTag(100) as? UILabel {
            label.text = collectionLabels[indexPath.row]
        }
        if let imageView = cell.viewWithTag(200) as? UIImageView {
            imageView.image = collectionImages[indexPath.row]
        }
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
