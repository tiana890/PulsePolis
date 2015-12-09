//
//  AvatarCollectionViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 09.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class AvatarCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.collection.contentInset
        let value = (self.view.frame.size.width - (self.collection.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.collection.contentInset = insets
        self.collection.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    //MARK: Collection view
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? AvatarCollectionViewCell{
            var img = UIImage(named:"photo_example")
            cell.avatarImage.image = img
            createMaskForImage(cell.avatarImage)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func createMaskForImage(image: UIImageView){
        let mask = CALayer()
        let maskImage = UIImage(named: "avatar_shape_big")
        mask.contents = maskImage?.CGImage
        mask.frame = CGRectMake(0, 0,maskImage!.size.width, maskImage!.size.height)
        image.layer.mask = mask
        image.layer.masksToBounds = true

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
