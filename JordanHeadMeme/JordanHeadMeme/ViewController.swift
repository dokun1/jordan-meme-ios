//
//  ViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
import SVProgressHUD
import Crashlytics
import TSMessages

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageEditingViewControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var demoHead: UIImageView!
    var demoHeadFacingRight = true
    var demoHeadUnmodified = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let numberOfScreenAppearances = NSUserDefaults.standardUserDefaults().integerForKey("screenAppearances") + 1
        NSUserDefaults.standardUserDefaults().setObject(numberOfScreenAppearances, forKey: "screenAppearances")
        NSUserDefaults.standardUserDefaults().synchronize()
        if numberOfScreenAppearances == 10 {
            shamelesslyBegUserForAppStoreReview()
        }
    }
    
    func shamelesslyBegUserForAppStoreReview() {
        let reviewController = UIAlertController.init(title: "App Store Review", message: "I hope you're enjoying using the app! Would you mind leaving a review on the App Store about it?", preferredStyle: .Alert)
        let yesAction = UIAlertAction.init(title: "Sure", style: .Cancel) { (UIAlertAction) -> Void in
            Analytics.logCustomEventWithName("App Review Alert View", customAttributes: ["Accepted":true])
            UIApplication.sharedApplication().openURL(NSURL.init(string: "itms-apps://itunes.apple.com/app/id1084796562")!)
        }
        let noAction = UIAlertAction.init(title: "Beat it, nerd", style: .Destructive) { (UIAlertAction) -> Void in
            Analytics.logCustomEventWithName("App Review Alert", customAttributes: ["Accepted":false])
        }
        reviewController.addAction(yesAction)
        reviewController.addAction(noAction)
        presentViewController(reviewController, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func takePhotoTapped() {
        // TODO: Track the user action that is important for you.
        Analytics.logCustomEventWithName("Photo Capture Began", customAttributes: ["Method":"Take Photo"])
        let picker = UIImagePickerController.init()
        picker.sourceType = .Camera
        presentPicker(picker)
    }
    
    @IBAction func takeSelfieTapped() {
        Analytics.logCustomEventWithName("Photo Capture Began", customAttributes: ["Method":"Take Selfie"])
        let picker = UIImagePickerController.init()
        picker.sourceType = .Camera
        picker.cameraDevice = .Front
        presentPicker(picker)
    }
    
    @IBAction func choosePhotoTapped() {
        Analytics.logCustomEventWithName("Photo Capture Began", customAttributes: ["Method":"Choose Photo"])
        let picker = UIImagePickerController.init()
        picker.sourceType = .PhotoLibrary
        presentPicker(picker)
    }
    
    func presentPicker(picker: UIImagePickerController) {
        picker.allowsEditing = false
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: GestureRecognizer methods
    
    @IBAction func rotationGestureActivated(recognizer: UIRotationGestureRecognizer) {
        logUserModifiedDemoHead()
        demoHeadUnmodified = false
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @IBAction func doubleTapGestureActivated(recognizer: UITapGestureRecognizer) {
        logUserModifiedDemoHead()
        demoHeadUnmodified = false
        if demoHeadFacingRight == true {
            demoHead.image = UIImage.init(named: "jordanHeadInverted.png")
        } else {
            demoHead.image = UIImage.init(named: "jordanHead.png")
        }
        demoHeadFacingRight = !demoHeadFacingRight
    }
    
    @IBAction func pinchGestureActivated(recognizer: UIPinchGestureRecognizer) {
        logUserModifiedDemoHead()
        demoHeadUnmodified = false
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func homeButtonTapped() {
        if demoHeadUnmodified == true {
            showInstructions()
        } else {
            let hasShownInstructions = NSUserDefaults.standardUserDefaults().boolForKey("firstTimeShowingInstructions")
            if hasShownInstructions == false {
                showInstructions()
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "firstTimeShowingInstructions")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            self.demoHead.userInteractionEnabled = false
            demoHead.image = UIImage.init(named: "jordanHead.png")
            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.demoHead.transform = CGAffineTransformMakeRotation(1)
                self.demoHead.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: { (Bool) -> Void in
                    self.self.demoHeadUnmodified = true
                    self.self.demoHead.userInteractionEnabled = true
            })
        }
    }
    
    func logUserModifiedDemoHead() {
        let userHasModifiedDemoHead = NSUserDefaults.standardUserDefaults().boolForKey("hasModifiedDemoHead")
        if userHasModifiedDemoHead == false {
            Analytics.logCustomEventWithName("User Tried Demo", customAttributes: nil)
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "hasModifiedDemoHead")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func showInstructions() {
        Analytics.logCustomEventWithName("Instructions Shown", customAttributes: nil)
        TSMessage.showNotificationInViewController(self, title: "Play with the head!", subtitle: "Try pinch-zooming, rotating, or double tapping the head on the screen to change its appearance.", type: .Message, duration: 5.0, canBeDismissedByUser: true)
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        Analytics.logCustomEventWithName("Photo Capture Completed", customAttributes: ["Got Photo":info[UIImagePickerControllerOriginalImage] != nil])
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("editImageSegue", sender: info[UIImagePickerControllerOriginalImage] as! UIImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        Analytics.logCustomEventWithName("Photo Capture Cancelled", customAttributes:nil)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editImageSegue") {
            let nextController:ImageEditingViewController = segue.destinationViewController as! ImageEditingViewController
            nextController.uneditedImage = sender as! UIImage
            nextController.delegate = self
        }
    }
    
    // MARK: ImageEditingViewControllerDelegate methods
    
    func controllerDidFinishWithImage(controller: ImageEditingViewController, image: UIImage) {
        controller.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func controllerDidCancel(controller: ImageEditingViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

