//
//  ImageEditingViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
import QuartzCore

protocol ImageEditingViewControllerDelegate: class {
    func controllerDidFinishWithImage(controller: ImageEditingViewController, image: UIImage)
    func controllerDidCancel(controller: ImageEditingViewController)
}

class ImageEditingViewController: UIViewController, UIGestureRecognizerDelegate {
    var uneditedImage: UIImage!
    var correctedImage: UIImage!
    var screensizeImage: UIImage!
    var imageView: UIImageView!
    weak var delegate: ImageEditingViewControllerDelegate?
    var generatedHeads: [JordanHead] = [JordanHead]()
    
    // MARK: override methods
    
    override func viewDidLoad() {
        correctedImage = uneditedImage.fixOrientation
        let newWidth = CGRectGetWidth(self.view.bounds)
        let newHeight = (newWidth / uneditedImage.size.width) * uneditedImage.size.height
        screensizeImage = correctedImage.resize(CGSizeMake(newWidth, newHeight))
        imageView = UIImageView.init(image: screensizeImage)
        imageView.frame = CGRectMake(0, 0, screensizeImage.size.width, screensizeImage.size.height)
        imageView.center = self.view.center
        imageView.userInteractionEnabled = true
        self.view.addSubview(imageView)
    }
    
    override func viewDidAppear(animated: Bool) {
        if let results = processImage() {
            var counter = 0
            for r in results {
                counter++
                let face: CIFaceFeature = r as! CIFaceFeature
                if face.hasLeftEyePosition && face.hasRightEyePosition && face.hasMouthPosition {
                    let jordanHead = drawJordanHead(getRectForDrawingHead(face), feature: face, tag: counter)
                    imageView.addSubview(jordanHead.imageView)
                    generatedHeads.append(jordanHead)
                }
            }
        }
    }
    
    // MARK: UI Drawing Methods

    func drawJordanHead(drawRect: CGRect, feature: CIFaceFeature, tag: Int) -> JordanHead {
        let jordanHead = JordanHead()
        let jordanHeadImage = UIImageView.init(image: UIImage.init(named: "jordanHead.png"))
        jordanHeadImage.frame = drawRect
        jordanHeadImage.contentMode = .ScaleAspectFit
        jordanHeadImage.backgroundColor = UIColor.clearColor()
        if feature.hasRightEyePosition && feature.hasLeftEyePosition {
            if feature.rightEyePosition.y > feature.leftEyePosition.y {
                jordanHeadImage.transform = CGAffineTransformMakeScale(-1, 1)
                jordanHead.facingRight = false
            }
        }
        jordanHeadImage.transform = CGAffineTransformMakeRotation(CGFloat(feature.faceAngle * Float(M_PI/180)))
        jordanHeadImage.userInteractionEnabled = true
        
        addGestureRecognizers(jordanHeadImage)
        jordanHeadImage.tag = tag
        jordanHead.imageView = jordanHeadImage
        jordanHead.faceID = tag
        jordanHead.faceFeature = feature
        return jordanHead
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
                if head.faceID == tag {
                    tappedHead = head
                    break
                }
            }
            guard (tappedHead != nil) else {
                return
            }
            // wtf why isnt this working
            if tappedHead?.facingRight == true {
                tappedHead?.imageView.transform = CGAffineTransformMakeScale(1, 1)
                tappedHead?.facingRight = true
            } else {
                tappedHead?.imageView.transform = CGAffineTransformMakeScale(-1, 1)
                tappedHead?.facingRight = false
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
    
    // MARK: Face detection methods
    
    func getRectForDrawingHead(detectedFace: CIFaceFeature) -> CGRect {
        var transform = CGAffineTransformMakeScale(1, -1)
        transform = CGAffineTransformTranslate(transform, 0, -imageView.bounds.size.height)
        var faceRect = CGRectApplyAffineTransform(detectedFace.bounds, transform)
        if detectedFace.hasLeftEyePosition && detectedFace.hasRightEyePosition {
            let higherPoint = (detectedFace.leftEyePosition.y > detectedFace.rightEyePosition.y ? detectedFace.leftEyePosition : detectedFace.rightEyePosition)
            let alteredPoint  = CGPointApplyAffineTransform(higherPoint, transform)
            let centerPoint = faceRect.rectCenter
            let distance = 3.14 * abs(centerPoint.y - alteredPoint.y)
            let alteredDistance = (faceRect.origin.y + faceRect.size.height) - (alteredPoint.y - distance)
            faceRect = CGRectMake(faceRect.origin.x, alteredPoint.y - distance, faceRect.size.width, alteredDistance)
        }
        return faceRect
    }

    func processImage() -> NSArray? {
        if let image = imageView.image {
            let ciImage = CIImage(CGImage: image.CGImage!)
            return getFaceDetector().featuresInImage(ciImage)
        } else {
            return nil
        }
    }

    func getFaceDetector() -> CIDetector {
        return CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonClicked() {
        delegate?.controllerDidFinishWithImage(self, image: imageView.image!)
    }
    
    @IBAction func cancelButtonClicked() {
        delegate?.controllerDidCancel(self)
    }
}