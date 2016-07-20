//
//  ViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
// import SVProgressHUD
import Crashlytics
// import TSMessages

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageEditingViewControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var demoHead: UIImageView!
    var demoHeadFacingRight = true
    var demoHeadUnmodified = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let numberOfScreenAppearances = UserDefaults.standard.integer(forKey: "screenAppearances") + 1
        UserDefaults.standard.set(numberOfScreenAppearances, forKey: "screenAppearances")
        UserDefaults.standard.synchronize()
        if numberOfScreenAppearances == 10 {
            shamelesslyBegUserForAppStoreReview()
        }
        // TSMessage.setDelegate(self)
    }
    
    func shamelesslyBegUserForAppStoreReview() {
        let reviewController = UIAlertController.init(title: "App Store Review", message: "I hope you're enjoying using the app! Would you mind leaving a review on the App Store about it?", preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: "Sure", style: .cancel) { (UIAlertAction) -> Void in
            Analytics.logCustomEventWithName("App Review Alert View", customAttributes: ["Accepted":true])
            UIApplication.shared().openURL(URL.init(string: "itms-apps://itunes.apple.com/app/id1084796562")!)
        }
        let noAction = UIAlertAction.init(title: "Beat it, nerd", style: .destructive) { (UIAlertAction) -> Void in
            Analytics.logCustomEventWithName("App Review Alert", customAttributes: ["Accepted":false])
        }
        reviewController.addAction(yesAction)
        reviewController.addAction(noAction)
        present(reviewController, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func takePhotoTapped() {
        // TODO: Track the user action that is important for you.
        Analytics.logCustomEventWithName("Photo Capture Began", customAttributes: ["Method":"Take Photo"])
        let picker = UIImagePickerController.init()
        picker.sourceType = .camera
        presentPicker(picker)
    }
    
    @IBAction func takeSelfieTapped() {
        Analytics.logCustomEventWithName("Photo Capture Began", customAttributes: ["Method":"Take Selfie"])
        let picker = UIImagePickerController.init()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        presentPicker(picker)
    }
    
    @IBAction func choosePhotoTapped() {
        Analytics.logCustomEventWithName("Photo Capture Began", customAttributes: ["Method":"Choose Photo"])
        let picker = UIImagePickerController.init()
        picker.sourceType = .photoLibrary
        presentPicker(picker)
    }
    
    func presentPicker(_ picker: UIImagePickerController) {
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: GestureRecognizer methods
    
    @IBAction func rotationGestureActivated(_ recognizer: UIRotationGestureRecognizer) {
        logUserModifiedDemoHead()
        demoHeadUnmodified = false
        if let view = recognizer.view {
            view.transform = view.transform.rotate(recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @IBAction func doubleTapGestureActivated(_ recognizer: UITapGestureRecognizer) {
        logUserModifiedDemoHead()
        demoHeadUnmodified = false
        if demoHeadFacingRight == true {
            demoHead.image = UIImage.init(named: "jordanHeadInverted.png")
        } else {
            demoHead.image = UIImage.init(named: "jordanHead.png")
        }
        demoHeadFacingRight = !demoHeadFacingRight
    }
    
    @IBAction func pinchGestureActivated(_ recognizer: UIPinchGestureRecognizer) {
        logUserModifiedDemoHead()
        demoHeadUnmodified = false
        if let view = recognizer.view {
            view.transform = view.transform.scaleBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func homeButtonTapped() {
        if demoHeadUnmodified == true {
            showInstructions()
        } else {
            let hasShownInstructions = UserDefaults.standard.bool(forKey: "firstTimeShowingInstructions")
            if hasShownInstructions == false {
                showInstructions()
                UserDefaults.standard.set(true, forKey: "firstTimeShowingInstructions")
                UserDefaults.standard.synchronize()
            }
            self.demoHead.isUserInteractionEnabled = false
            demoHead.image = UIImage.init(named: "jordanHead.png")
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.demoHead.transform = CGAffineTransform(rotationAngle: 1)
                self.demoHead.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: { (Bool) -> Void in
                    self.self.demoHeadUnmodified = true
                    self.self.demoHead.isUserInteractionEnabled = true
            })
        }
    }
    
    func logUserModifiedDemoHead() {
        let userHasModifiedDemoHead = UserDefaults.standard.bool(forKey: "hasModifiedDemoHead")
        if userHasModifiedDemoHead == false {
            Analytics.logCustomEventWithName("User Tried Demo", customAttributes: nil)
            UserDefaults.standard.set(true, forKey: "hasModifiedDemoHead")
            UserDefaults.standard.synchronize()
        }
    }
    
    func showInstructions() {
        Analytics.logCustomEventWithName("Instructions Shown", customAttributes: nil)
        // TSMessage.addCustomDesignFromFile(withName: "JordanHeadMemeMessageCustomization.json")
        // TSMessage.showNotification(in: self, title: "Play with the head!", subtitle: "Try pinch-zooming, rotating, or double tapping the head on the screen to change its appearance.", type: .message, duration: 5.0, canBeDismissedByUser: true)
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        Analytics.logCustomEventWithName("Photo Capture Completed", customAttributes: ["Got Photo":info[UIImagePickerControllerOriginalImage] != nil])
        picker.dismiss(animated: true) { () -> Void in
            self.performSegue(withIdentifier: "editImageSegue", sender: info[UIImagePickerControllerOriginalImage] as! UIImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Analytics.logCustomEventWithName("Photo Capture Cancelled", customAttributes:nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editImageSegue") {
            let nextController:ImageEditingViewController = segue.destinationViewController as! ImageEditingViewController
            nextController.uneditedImage = sender as! UIImage
            nextController.delegate = self
        }
    }
    
    // MARK: TSMessageDelegate Methods
    
//    func customize(_ messageView: TSMessageView!) {
//        messageView.alpha = 1
//    }
    
    // MARK: ImageEditingViewControllerDelegate methods
    
    func controllerDidFinishWithImage(_ controller: ImageEditingViewController, image: UIImage) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func controllerDidCancel(_ controller: ImageEditingViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

