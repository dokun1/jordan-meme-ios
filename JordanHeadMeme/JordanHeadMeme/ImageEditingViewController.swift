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

protocol ImageEditingViewControllerDelegate: class {
    func controllerDidFinishWithImage(controller: ImageEditingViewController, image: UIImage)
    func controllerDidCancel(controller: ImageEditingViewController)
}

class ImageEditingViewController: UIViewController, UIGestureRecognizerDelegate {
    var uneditedImage: UIImage!
    var correctedImage: UIImage!
    var imageView: UIImageView!
    weak var delegate: ImageEditingViewControllerDelegate?
    var headViews: [UIImageView] = [UIImageView]()
    var generatedHeads: [JordanHead] = [JordanHead]()
    
    // MARK: override methods
    
    override func viewDidLoad() {
        SVProgressHUD.showWithStatus("Applying heads...")
        correctedImage = uneditedImage.fixOrientation
        imageView = UIImageView.init(image: correctedImage)
        imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))
        imageView.frame = CGRectMake(0, 0, correctedImage.size.width, correctedImage.size.height)
        imageView.center = self.view.center
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFit
    }
    
    override func viewDidAppear(animated: Bool) {
        arrangeJordanHeads()
    }
    
    // MARK: Image processing methods
    
    func arrangeJordanHeads() {
        let results = ImageProcessor.processImage(correctedImage)
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
        imageView.center = self.view.center
        if results?.count == 0 {
            SVProgressHUD.showErrorWithStatus("Could not find any faces")
        } else {
            SVProgressHUD.dismiss()
        }
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func getImageViewForHead(head: JordanHead) -> UIImageView {
        let jordanHeadImage = UIImageView.init(image: UIImage.init(named: "jordanHead.png"))
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
    
    // MARK: Gesture Recognizer Targets
    
    func rotationGestureActivated(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func panGestureActivated(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.imageView)
        if let view = recognizer.view {
            view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
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
    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonClicked() {
        delegate?.controllerDidFinishWithImage(self, image: imageView.image!)
    }
    
    @IBAction func cancelButtonClicked() {
        delegate?.controllerDidCancel(self)
    }
    
    @IBAction func saveButtonTapped() {
        SVProgressHUD.showWithStatus("Saving image...")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let newImage = self.imageView.convertToImage(self.correctedImage.size)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
                SVProgressHUD.dismiss()
                self.self.delegate?.controllerDidCancel(self)
            })
        }
    }
}