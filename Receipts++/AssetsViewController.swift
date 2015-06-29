//
//  ViewController.swift
//  MultipleAssetPicker
//
//  Created by Daniel Mathews on 2015-03-08.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class AssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let AssetCollectionViewCellResuseIdentifier = "AssetCell"
    
    var assetsFetchResults:PHFetchResult?
    var selectedAssets = [PHAsset]()
    
    let picker = UIImagePickerController()
    
    private let imageManager = PHCachingImageManager()
    
    var cellSize = CGSize(width: 125, height: (125 + CGFloat(25)))
    
    var nextBarButtonItem: UIBarButtonItem?
    
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
        
        //PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
        nextBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: "nextButtonPressed:");
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedAssets = [PHAsset]()
        nextBarButtonItem?.title = ""
        nextBarButtonItem?.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var thumbsPerRow: Int
        switch collectionView.bounds.size.width {
        case 0..<400:
            thumbsPerRow = 3
        case 400..<600:
            thumbsPerRow = 4
        case 600..<800:
            thumbsPerRow = 5
        case 800..<1200:
            thumbsPerRow = 6
        default:
            thumbsPerRow = 3
        }
        let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
        cellSize = CGSize(width: width,height: (width + CGFloat(25)))
        
        return cellSize
    }
    
    func showNoAccessAlertAndCancel() {
        let alert = UIAlertController(title: "No Photo Permission", message: "Please grant photo access in Settings -> Privacy", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            print("pressed cancel")
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotoLabelVC") {
            // pass data to next view
            let vc = segue.destinationViewController as! AddLabelViewController
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
        
        if let assetsCount = assetsFetchResults?.count{
            return assetsFetchResults!.count + 1
        } else{
            return assetsFetchResults?.count ?? 1
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch (indexPath.item){
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TakePhoto", forIndexPath: indexPath) as UICollectionViewCell

            return cell

        default:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AssetCollectionViewCellResuseIdentifier, forIndexPath: indexPath) as! AssetCell
            
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
                targetSize: cellSize,
                contentMode: .AspectFill, options: options)
                { result, info in
                    if reuseCount == cell.reuseCount {
                        cell.imageView.image = result
                    }
                }
            
            return cell
        }
    }
    
    @IBAction func pressedTakeButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera;
            picker.mediaTypes = [kUTTypeImage]
            picker.allowsEditing = false
            
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            print("cannot load UIImagePicker Camera")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        
        let newImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(newImage)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            
            let collectionFetchResults = PHAssetCollection.fetchTopLevelUserCollectionsWithOptions(nil)

            if let first_obj: AnyObject = collectionFetchResults.firstObject {
                let wholeAlbumCollection = collectionFetchResults.firstObject as! PHAssetCollection
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: wholeAlbumCollection)
            
                albumChangeRequest.addAssets([assetPlaceholder])
                }
            }, completionHandler: { success, error in
                print("added image to album")
                self.fetchCollections()
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView!.reloadData()
                }
        })

    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
        if indexPath.item > 0{
            let asset = currentAssetAtIndex(indexPath.item)!
            selectedAssets.append(asset)
            switch selectedAssets.count{
            case 1:
                nextBarButtonItem?.title = "Next(\(selectedAssets.count))"
                nextBarButtonItem?.enabled = true
                navigationItem.rightBarButtonItem = nextBarButtonItem;
            default:
                nextBarButtonItem?.title = "Next(\(selectedAssets.count))"
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
        if indexPath.item > 0{
            let assetToDelete = currentAssetAtIndex(indexPath.item)
            selectedAssets = selectedAssets.filter { asset in
                !(asset == assetToDelete)
            }
            switch selectedAssets.count{
            case 0:
                nextBarButtonItem?.title = ""
                nextBarButtonItem?.enabled = false
            default:
                nextBarButtonItem?.title = "Next(\(selectedAssets.count))"
            }

        }
    }
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        // Respond to changes
        dispatch_async(dispatch_get_main_queue()) {
            // 1
            var changeDetails: PHFetchResultChangeDetails? =
            changeInstance.changeDetailsForFetchResult(self.assetsFetchResults)
            if let changes = changeDetails {
                self.assetsFetchResults = changes.fetchResultAfterChanges
                self.collectionView?.reloadData()
            }
        }
    }
    
    func nextButtonPressed(sender: UIBarButtonItem) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addLabelVC = storyboard.instantiateViewControllerWithIdentifier("addLabelVC") as! AddLabelViewController
        addLabelVC.selectedAssets = selectedAssets
        //println("selectedAssets is \(selectedAssets)")
        //navigationController?.pushViewController(addLabelVC, animated: true)
        presentViewController(addLabelVC, animated: true, completion: {
            self.navigationController?.popToRootViewControllerAnimated(false)
            return
        })
    }
    
    // MARK: Private
    func currentAssetAtIndex(index:NSInteger) -> PHAsset? {
        if let fetchResult = assetsFetchResults{
            return fetchResult[index-1] as! PHAsset?
        }else{
            return nil
        }
    }
    
//    func updateSelectedItems() {
//        // Select the selected items
//        if let fetchResult = assetsFetchResults {
//            // 1
//            for asset in selectedAssets {
//                let index = fetchResult.indexOfObject(asset)
//                if index == NSNotFound {
//                    let indexPath = NSIndexPath(forItem: index, inSection: 0)
//                    collectionView!.selectItemAtIndexPath(indexPath,
//                        animated: false, scrollPosition: .None)
//                }
//            }
//        }
//    }
    

}

