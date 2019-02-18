//
//  IconSelectCollectionViewController.swift
//  MindWaveJournaler
//
//  Created by Casey Brittain on 2/16/19.
//  Copyright © 2019 Honeysuckle Hardware. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class IconSelectCollectionViewController: UICollectionViewController {
    
    var activity = Activity()
    var collectionImages: [UIImage] = []
    @IBOutlet var iconCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let width = (view.frame.size.width - 40) / 2
        let layout = iconCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)

        
        // Load icon images.
        for i in 1...numberOfActivityIcons {
            if let image = UIImage(named: "activity_" + String(i)) {
                print(i)
                collectionImages.append(image)
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath)
        if let imageView = cell.viewWithTag(200) as? UIImageView {
            imageView.image = collectionImages[indexPath.row]
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Set activity image then return to creation view.
        activity.imageName = "activity_" + String(indexPath.row + 1)
        self.navigationController?.popViewController(animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
