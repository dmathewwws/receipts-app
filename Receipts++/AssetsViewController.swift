//
//  ViewController.swift
//  MultipleAssetPicker
//
//  Created by Daniel Mathews on 2015-03-08.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import Photos

class AssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {

    let AssetCollectionViewCellResuseIdentifier = "AssetCell"
    
    var assetsFetchResults:PHFetchResult?
    var selectedAssets = [PHAsset]()
    
    private let imageManager = PHCachingImageManager()
    
    let collectionViewEdgeInsets = CGFloat(10.0)
    
//    let screenBounds = UIScreen.mainScreen().bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView!.allowsMultipleSelection = true
        
        PHPhotoLibrary.requestAuthorization { status in
            dispatch_async(dispatch_get_main_queue()) {
                switch status{
                case .Authorized:
                    self.fetchCollections()
                    self.collectionView!.reloadData()
                default:
                    self.showNoAccessAlertAndCancel()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        updateSelectedItems()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionViewEdgeInsets, left: collectionViewEdgeInsets, bottom: 0, right: collectionViewEdgeInsets)
    }
    
    func showNoAccessAlertAndCancel() {
        let alert = UIAlertController(title: "No Photo Permission", message: "Please grant photo access in Settings -> Privacy", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            println("pressed cancel")
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }))
        
        //self.presentViewController(<#viewControllerToPresent: UIViewController#>, animated: <#Bool#>, completion: <#(() -> Void)?##() -> Void#>)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotoLabelVC") {
            // pass data to next view
            let vc = segue.destinationViewController as AddLabelViewController
            vc.selectedAssets = selectedAssets
        }
    }
    
    func fetchCollections(){
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assetsFetchResults = PHAsset.fetchAssetsWithOptions(options)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults?.count ?? 0
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AssetCollectionViewCellResuseIdentifier, forIndexPath: indexPath) as AssetCell
        
        // Populate Cell
        // 1
        let reuseCount = ++cell.reuseCount
        let asset = currentAssetAtIndex(indexPath.item)
        // 2
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        // 3
        imageManager.requestImageForAsset(asset,
            targetSize: CGSize(width: 100, height: 100),
            contentMode: .AspectFill, options: options)
            { result, info in
                if reuseCount == cell.reuseCount {
                    cell.imageView.image = result
                }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
        let asset = currentAssetAtIndex(indexPath.item)!
        selectedAssets.append(asset)
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
        let assetToDelete = currentAssetAtIndex(indexPath.item)
        selectedAssets = selectedAssets.filter { asset in
            !(asset == assetToDelete)
        }
    }
    
    func photoLibraryDidChange(changeInstance: PHChange!) {
        println(changeInstance.description)
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView!.reloadData()
        }
    }
    
    // MARK: Private
    func currentAssetAtIndex(index:NSInteger) -> PHAsset? {
        if let fetchResult = assetsFetchResults{
            return fetchResult[index] as PHAsset?
        }else{
            return nil
        }
    }
    
    func updateSelectedItems() {
        // Select the selected items
        if let fetchResult = assetsFetchResults {
            // 1
            for asset in selectedAssets {
                let index = fetchResult.indexOfObject(asset)
                if index == NSNotFound {
                    let indexPath = NSIndexPath(forItem: index, inSection: 0)
                    collectionView!.selectItemAtIndexPath(indexPath,
                        animated: false, scrollPosition: .None)
                }
            }
        }
    }
    

}

