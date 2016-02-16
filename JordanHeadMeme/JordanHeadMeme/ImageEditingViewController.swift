//
//  ImageEditingViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import SVProgressHUD
import Crashlytics

protocol ImageEditingViewControllerDelegate: class {
    func controllerDidFinishWithImage(controller: ImageEditingViewController, image: UIImage)
    func controllerDidCancel(controller: ImageEditingViewController)
}

class ImageEditingViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    weak var delegate: ImageEditingViewControllerDelegate?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var uneditedImage: UIImage!
    var correctedImage: UIImage!
    var imageView: UIImageView!
    
    var headViews: [UIImageView] = [UIImageView]()
    var generatedHeads: [JordanHead] = [JordanHead]()
    var hasMadeImage = false
    var removingHead = false
    
    // MARK: override methods
    
    override func viewDidLoad() {
        loadImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        if hasMadeImage == false {
            arrangeJordanHeads()
            hasMadeImage = true
        }
    }
    
    // MARK: UIScrollViewDelegate Methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        
        self.imageView.frame = contentsFrame;
    }
    
    // MARK: Image processing methods
    
    func loadImage() {
        SVProgressHUD.showWithStatus("Applying heads...")
        correctedImage = uneditedImage.fixOrientation
        imageView = UIImageView.init(image: correctedImage)
        imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))
        imageView.frame = CGRectMake(0, 0, correctedImage.size.width, correctedImage.size.height)
        imageView.center = self.view.center
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFit
    }
    
    func arrangeJordanHeads() {
        let results = ImageProcessor.processImage(correctedImage)
        Answers.logCustomEventWithName("Heads Generated", customAttributes:["Count":(results?.count)!])
        for head in results! {
            let headView = getImageViewForHead(head)
            headView.tag = head.id
            addGestureRecognizers(headView)
            imageView.addSubview(headView)
            headViews.append(headView)
            generatedHeads.append(head)
        }
        let resizeFactor = UIScreen.mainScreen().bounds.size.width / imageView.frame.size.width
        imageView.transform = CGAffineTransformMakeScale(resizeFactor, resizeFactor)
        scrollView.minimumZoomScale = resizeFactor
        imageView.center = scrollView.center
        if results?.count == 0 {
            SVProgressHUD.showErrorWithStatus("Could not find any faces")
        } else {
            SVProgressHUD.dismiss()
        }
        scrollView.addSubview(imageView)
        scrollView.sendSubviewToBack(imageView)
        self.view.sendSubviewToBack(scrollView)
        addEntirePhotoGestureRecognizers()
    }
    
    func getImageViewForHead(head: JordanHead) -> JordanHeadImageView {
        let jordanHeadImage = JordanHeadImageView.init(head: head)
        jordanHeadImage.frame = head.rect
        jordanHeadImage.contentMode = .ScaleAspectFit
        jordanHeadImage.backgroundColor = UIColor.clearColor()
        if head.faceFeature.hasRightEyePosition && head.faceFeature.hasLeftEyePosition {
            if head.faceFeature.rightEyePosition.y > head.faceFeature.leftEyePosition.y {
                jordanHeadImage.image = UIImage.init(named: "jordanHeadInverted.png")
                head.facingRight = false
            }
        }
        jordanHeadImage.transform = CGAffineTransformMakeRotation(CGFloat(head.faceFeature.faceAngle * Float(M_PI/180)))
        jordanHeadImage.userInteractionEnabled = true
        return jordanHeadImage
    }
    
    // MARK: UI Drawing Methods
    
    func addNewHead(rect: CGRect) {
        setAllButtonsEnabled(false)
        var highestID = 0
        for head in generatedHeads {
            highestID = max(highestID, head.id)
        }
        let newHead = JordanHead()
        newHead.rect = rect
        newHead.facingRight = true
        newHead.id = highestID + 1
        let newHeadView = getImageViewForHead(newHead)
        newHeadView.tag = newHead.id
        addGestureRecognizers(newHeadView)
        imageView.addSubview(newHeadView)
        headViews.append(newHeadView)
        generatedHeads.append(newHead)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        setAllButtonsEnabled(true)
    }
    
    func makeHeadDisappear(head: JordanHeadImageView) {
        if removingHead == false {
            removingHead = true
            UIView.animateWithDuration(0.3, animations: {
                head.alpha = 0
                }, completion: {
                    (value: Bool) in
                    head.removeFromSuperview()
                    self.removingHead = false
            })
        }
    }
    
    func addGestureRecognizers(head: UIImageView) {
        let panner = UIPanGestureRecognizer.init(target: self, action: Selector("panGestureActivated:"))
        panner.delegate = self
        head.addGestureRecognizer(panner)
        
        let doubleTapper = UITapGestureRecognizer.init(target: self, action: Selector("doubleTapGestureActivated:"))
        doubleTapper.numberOfTouchesRequired = 1
        doubleTapper.numberOfTapsRequired = 2
        doubleTapper.delegate = self
        head.addGestureRecognizer(doubleTapper)
        
        let pincher = UIPinchGestureRecognizer.init(target: self, action: Selector("pinchGestureActivated:"))
        pincher.delegate = self
        head.addGestureRecognizer(pincher)
        
        let rotator = UIRotationGestureRecognizer.init(target: self, action: Selector("rotationGestureActivated:"))
        rotator.delegate = self
        head.addGestureRecognizer(rotator)
    }

    func addEntirePhotoGestureRecognizers() {
        let doubleTapper = UITapGestureRecognizer.init(target: self, action: Selector("doubleTapGestureActivatedMainView:"))
        doubleTapper.numberOfTouchesRequired = 1
        doubleTapper.numberOfTapsRequired = 2
        doubleTapper.delegate = self
        scrollView.addGestureRecognizer(doubleTapper)
    }
    
    // MARK: Gesture Recognizer Targets
    
    func rotationGestureActivated(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func panGestureActivated(recognizer: UIPanGestureRecognizer) {
        if (recognizer.velocityInView(imageView).y > 12000 || recognizer.velocityInView(imageView).y < -12000) && recognizer.view is JordanHeadImageView {
            makeHeadDisappear(recognizer.view as! JordanHeadImageView)
        } else {
            let translation = recognizer.translationInView(self.imageView)
            if let view = recognizer.view {
                view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y)
            }
            recognizer.setTranslation(CGPointZero, inView: self.view)
        }
    }
    
    func doubleTapGestureActivated(recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let tag = imageView.tag
            var tappedHead: JordanHead?
            for head in generatedHeads {
                if head.id == tag {
                    tappedHead = head
                    break
                }
            }
            guard (tappedHead != nil) else {
                return
            }
            // wtf why isnt this working
            if tappedHead?.facingRight == true {
                imageView.image = UIImage.init(named: "jordanHeadInverted.png")
                tappedHead?.facingRight = false
            } else {
                imageView.image = UIImage.init(named: "jordanHead.png")
                tappedHead?.facingRight = true
            }
        }
    }
    
    func pinchGestureActivated(recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    func doubleTapGestureActivatedMainView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale { // zoom in at point
            let newZoomScale = max(CGFloat(scrollView.zoomScale * 3), 3)
            
            let percentX = recognizer.locationInView(scrollView).x / scrollView.frame.size.width
            let percentY = recognizer.locationInView(scrollView).y / scrollView.frame.size.height
            
            let translatedPoint = CGPointMake(correctedImage.size.width * percentX, correctedImage.size.height * percentY)
            
            let size = correctedImage.size
            let w = size.width / newZoomScale
            let h = size.height / newZoomScale
            let x = translatedPoint.x - (w / 2)
            let y = translatedPoint.y - (h / 2)
            
            let rectToZoomTo = CGRectMake(x, y, w, h)
            scrollView.zoomToRect(rectToZoomTo, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view is JordanHeadImageView && otherGestureRecognizer.view is JordanHeadImageView { // we dont want both the scroll view and the jordan head to zoom simultaneously
            return true
        } else {
            return false
        }
    }
    
    // MARK: IBActions
    
    func setAllButtonsEnabled(enabled: Bool) {
        shareButton.enabled = enabled
        saveButton.enabled = enabled
        addButton.enabled = enabled
        doneButton.enabled = enabled
    }
    
    @IBAction func doneButtonClicked() {
        setAllButtonsEnabled(false)
        delegate?.controllerDidFinishWithImage(self, image: imageView.image!)
    }
    
    @IBAction func saveButtonTapped() {
        Answers.logCustomEventWithName("Photo Saved", customAttributes: nil)
        setAllButtonsEnabled(false)
        SVProgressHUD.showWithStatus("Saving image...")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let newImage = self.imageView.convertToImage(self.correctedImage.size)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
                SVProgressHUD.dismiss()
                self.setAllButtonsEnabled(true)
            })
        }
    }
    
    @IBAction func shareButtonTapped() {
        Answers.logCustomEventWithName("Share Button Tapped", customAttributes: nil)
        setAllButtonsEnabled(false)
        SVProgressHUD.showWithStatus("Preparing image...")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let activityViewController = UIActivityViewController(activityItems: [self.imageView.convertToImage(self.correctedImage.size)], applicationActivities: nil)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = self.shareButton
                }
                activityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) in
                    Answers.logCustomEventWithName("Photo Shared", customAttributes: ["ShareType":activityType!, "Completed":completed])
                }
                self.presentViewController(activityViewController, animated: true, completion: nil)
                self.setAllButtonsEnabled(true)
            })
        }
    }
    
    @IBAction func addButtonTapped() {
        addNewHead(CGRectMake(10, 10, correctedImage.size.width / 5, correctedImage.size.height / 5))
    }
}