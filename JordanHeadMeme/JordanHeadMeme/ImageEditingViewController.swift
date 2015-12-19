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

class ImageEditingViewController: UIViewController {
    var uneditedImage: UIImage!
    var correctedImage: UIImage!
    var screensizeImage: UIImage!
    var imageView: UIImageView!
    weak var delegate: ImageEditingViewControllerDelegate?
    
    // MARK: override methods
    
    override func viewDidLoad() {
        correctedImage = uneditedImage.fixOrientation
        let newWidth = CGRectGetWidth(self.view.bounds)
        let newHeight = (newWidth / uneditedImage.size.width) * uneditedImage.size.height
        screensizeImage = correctedImage.resize(CGSizeMake(newWidth, newHeight))
        imageView = UIImageView.init(image: screensizeImage)
        imageView.frame = CGRectMake(0, 0, screensizeImage.size.width, screensizeImage.size.height)
        imageView.center = self.view.center
        self.view.addSubview(imageView)
    }
    
    override func viewDidAppear(animated: Bool) {
        if let results = processImage() {
            for r in results {
                let face: CIFaceFeature = r as! CIFaceFeature
                if face.hasLeftEyePosition && face.hasRightEyePosition && face.hasMouthPosition {
                    imageView.addSubview(drawJordanHead(getRectForDrawingHead(face), feature: face))
                }
            }
        }
    }
    
    // MARK: UI Drawing Methods

    func drawJordanHead(drawRect: CGRect, feature: CIFaceFeature) -> UIImageView {
        let jordanHead = UIImageView.init(image: UIImage.init(named: "jordanHead.png"))
        jordanHead.frame = drawRect
        jordanHead.contentMode = .ScaleAspectFit
        jordanHead.backgroundColor = UIColor.clearColor()
        jordanHead.transform = CGAffineTransformMakeRotation(CGFloat(feature.faceAngle * Float(M_PI/180)))
        if feature.hasRightEyePosition && feature.hasLeftEyePosition {
            if feature.rightEyePosition.y > feature.leftEyePosition.y {
                jordanHead.transform = CGAffineTransformMakeScale(-1, 1)
            }
        }
        return jordanHead
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