//
//  ImageEditingViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
import QuartzCore
// import SVProgressHUD
import Crashlytics

protocol ImageEditingViewControllerDelegate: class {
    func controllerDidFinishWithImage(_ controller: ImageEditingViewController, image: UIImage)
    func controllerDidCancel(_ controller: ImageEditingViewController)
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
    
    override func viewDidAppear(_ animated: Bool) {
        if hasMadeImage == false {
            arrangeJordanHeads()
            hasMadeImage = true
        }
    }
    
    // MARK: UIScrollViewDelegate Methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
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
//        SVProgressHUD.show(withStatus: "Applying heads...")
        correctedImage = uneditedImage.fixOrientation
        imageView = UIImageView.init(image: correctedImage)
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        imageView.frame = CGRect(x: 0, y: 0, width: correctedImage.size.width, height: correctedImage.size.height)
        imageView.center = self.view.center
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
    }
    
    func arrangeJordanHeads() {
        let results = ImageProcessor.processImage(correctedImage)
        Analytics.logCustomEventWithName("Heads Generated", customAttributes:["Count":(results?.count)!, "Head Count":(results?.count)!])
        for head in results! {
            let headView = getImageViewForHead(head)
            headView.tag = head.id
            addGestureRecognizers(headView)
            imageView.addSubview(headView)
            headViews.append(headView)
            generatedHeads.append(head)
        }
        let resizeFactor = UIScreen.main().bounds.size.width / imageView.frame.size.width
        imageView.transform = CGAffineTransform(scaleX: resizeFactor, y: resizeFactor)
        scrollView.minimumZoomScale = resizeFactor
        imageView.center = scrollView.center
        if results?.count == 0 {
            // SVProgressHUD.showError(withStatus: "Could not find any faces")
        } else {
            // SVProgressHUD.dismiss()
        }
        scrollView.addSubview(imageView)
        scrollView.sendSubview(toBack: imageView)
        self.view.sendSubview(toBack: scrollView)
        addEntirePhotoGestureRecognizers()
    }
    
    func getImageViewForHead(_ head: JordanHead) -> JordanHeadImageView {
        let jordanHeadImage = JordanHeadImageView.init(head: head)
        jordanHeadImage.frame = head.rect
        jordanHeadImage.contentMode = .scaleAspectFit
        jordanHeadImage.backgroundColor = UIColor.clear()
        if head.faceFeature.hasRightEyePosition && head.faceFeature.hasLeftEyePosition {
            if head.faceFeature.rightEyePosition.y > head.faceFeature.leftEyePosition.y {
                jordanHeadImage.image = UIImage.init(named: "jordanHeadInverted.png")
                head.facingRight = false
            } else {
                head.facingRight = true
            }
        }
        jordanHeadImage.transform = CGAffineTransform(rotationAngle: CGFloat(head.faceFeature.faceAngle * Float(M_PI/180)))
        jordanHeadImage.isUserInteractionEnabled = true
        return jordanHeadImage
    }
    
    // MARK: UI Drawing Methods
    
    func addNewHead(_ rect: CGRect) {
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
    
    func makeHeadDisappear(_ head: JordanHeadImageView) {
        if removingHead == false {
            removingHead = true
            UIView.animate(withDuration: 0.3, animations: {
                head.alpha = 0
                }, completion: {
                    (value: Bool) in
                    head.removeFromSuperview()
                    self.removingHead = false
            })
        }
    }
    
    func addGestureRecognizers(_ head: UIImageView) {
        let panner = UIPanGestureRecognizer.init(target: self, action: #selector(ImageEditingViewController.panGestureActivated(_:)))
        panner.delegate = self
        head.addGestureRecognizer(panner)
        
        let doubleTapper = UITapGestureRecognizer.init(target: self, action: #selector(ImageEditingViewController.doubleTapGestureActivated(_:)))
        doubleTapper.numberOfTouchesRequired = 1
        doubleTapper.numberOfTapsRequired = 2
        doubleTapper.delegate = self
        head.addGestureRecognizer(doubleTapper)
        
        let pincher = UIPinchGestureRecognizer.init(target: self, action: #selector(ImageEditingViewController.pinchGestureActivated(_:)))
        pincher.delegate = self
        head.addGestureRecognizer(pincher)
        
        let rotator = UIRotationGestureRecognizer.init(target: self, action: #selector(ImageEditingViewController.rotationGestureActivated(_:)))
        rotator.delegate = self
        head.addGestureRecognizer(rotator)
    }

    func addEntirePhotoGestureRecognizers() {
        let doubleTapper = UITapGestureRecognizer.init(target: self, action: #selector(ImageEditingViewController.doubleTapGestureActivatedMainView(_:)))
        doubleTapper.numberOfTouchesRequired = 1
        doubleTapper.numberOfTapsRequired = 2
        doubleTapper.delegate = self
        scrollView.addGestureRecognizer(doubleTapper)
    }
    
    // MARK: Gesture Recognizer Targets
    
    func rotationGestureActivated(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotate(recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func panGestureActivated(_ recognizer: UIPanGestureRecognizer) {
        if (recognizer.velocity(in: imageView).y > 12000 || recognizer.velocity(in: imageView).y < -12000) && recognizer.view is JordanHeadImageView {
            makeHeadDisappear(recognizer.view as! JordanHeadImageView)
        } else {
            let translation = recognizer.translation(in: self.imageView)
            if let view = recognizer.view {
                view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            }
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    func doubleTapGestureActivated(_ recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            let tag = imageView.tag
            var tappedHead: JordanHead = JordanHead()
            tappedHead.id = 0 // no active head should have a tag of 0 so this can be our acceptance criteria
            for head in generatedHeads {
                if head.id == tag {
                    tappedHead = head
                    break
                }
            }
            guard (tappedHead != 0) else {
                return
            }
            if tappedHead.facingRight == true {
                imageView.image = UIImage.init(named: "jordanHeadInverted.png")
                tappedHead.facingRight = false
            } else {
                imageView.image = UIImage.init(named: "jordanHead.png")
                tappedHead.facingRight = true
            }
        }
    }
    
    func pinchGestureActivated(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaleBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    func doubleTapGestureActivatedMainView(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale { // zoom in at point
            let newZoomScale = max(CGFloat(scrollView.zoomScale * 3), 3)
            
            let percentX = recognizer.location(in: scrollView).x / scrollView.frame.size.width
            let percentY = recognizer.location(in: scrollView).y / scrollView.frame.size.height
            
            let translatedPoint = CGPoint(x: correctedImage.size.width * percentX, y: correctedImage.size.height * percentY)
            
            let size = correctedImage.size
            let w = size.width / newZoomScale
            let h = size.height / newZoomScale
            let x = translatedPoint.x - (w / 2)
            let y = translatedPoint.y - (h / 2)
            
            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
            scrollView.zoom(to: rectToZoomTo, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view is JordanHeadImageView && otherGestureRecognizer.view is JordanHeadImageView {
            // we dont want both the scroll view and the jordan head to zoom simultaneously
            return true
        } else {
            return false
        }
    }
    
    // MARK: IBActions
    
    func setAllButtonsEnabled(_ enabled: Bool) {
        shareButton.isEnabled = enabled
        saveButton.isEnabled = enabled
        addButton.isEnabled = enabled
        doneButton.isEnabled = enabled
    }
    
    @IBAction func doneButtonClicked() {
        setAllButtonsEnabled(false)
        delegate?.controllerDidFinishWithImage(self, image: imageView.image!)
    }
    
    @IBAction func saveButtonTapped() {
        Analytics.logCustomEventWithName("Photo Saved", customAttributes: nil)
        setAllButtonsEnabled(false)
        // SVProgressHUD.show(withStatus: "Saving image...")
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInitiated).async {
            if let newImage = self.imageView.convertToImage(self.correctedImage.size) { // this can be refactored
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
                    // notify the user that saving is done
                    self.setAllButtonsEnabled(true)
                }
            } else {
                DispatchQueue.main.async {
                    // notify the user of an error with an SVProgressHUD in the future
                    self.setAllButtonsEnabled(true)
                }
            }
        }
    }
    
    @IBAction func shareButtonTapped() {
        Analytics.logCustomEventWithName("Share Button Tapped", customAttributes: nil)
        setAllButtonsEnabled(false)
        // SVProgressHUD.show(withStatus: "Preparing image...")
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosUserInteractive).async {
            let activityViewController = UIActivityViewController(activityItems: [self.imageView.convertToImage(self.correctedImage.size)!], applicationActivities: nil)
            DispatchQueue.main.async {
                // SVProgressHUD.dismiss()
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = self.shareButton
                }
                activityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) in
                    if activityType != nil {
                        Analytics.logCustomEventWithName("Photo Shared", customAttributes: ["ShareType":activityType!, "Completed":completed])
                    }
                }
                self.present(activityViewController, animated: true, completion: nil)
                self.setAllButtonsEnabled(true)
            }
        }
    }
    
    @IBAction func addButtonTapped() {
        addNewHead(CGRect(x: 10, y: 10, width: correctedImage.size.width / 5, height: correctedImage.size.height / 5))
    }
}
