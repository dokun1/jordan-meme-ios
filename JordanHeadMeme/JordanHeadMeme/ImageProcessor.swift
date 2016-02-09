//
//  ImageProcessor.swift
//  JordanHeadMeme
//
//  Created by David Okun on 2/8/16.
//  Copyright © 2016 David Okun, LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class ImageProcessor: NSObject {
    
    // MARK : Public processing functions
    
    class func rectInImage(imageSize: CGSize) -> CGRect {
        return CGRectNull
    }

    class func processImage(image: UIImage) -> [JordanHead]?  {
        let ciImage = CIImage(CGImage: image.CGImage!)
        let results = getFaceDetector().featuresInImage(ciImage)
        var counter = 0
        var generatedHeads: [JordanHead] = [JordanHead]()
        for r in results {
            counter++
            let face: CIFaceFeature = r as! CIFaceFeature
            if face.hasLeftEyePosition && face.hasRightEyePosition && face.hasMouthPosition {
                let jordanHead = drawJordanHead(getRectForDrawingHead(face, image: image), feature: face, tag: counter)
                generatedHeads.append(jordanHead)
            }
        }
        return generatedHeads
    }
    
    // MARK : Private processing functions
    
    private class func getFaceDetector() -> CIDetector {
        return CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    }
    
    private class func drawJordanHead(drawRect: CGRect, feature: CIFaceFeature, tag: Int) -> JordanHead {
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
        jordanHeadImage.tag = tag
        jordanHead.id = tag
        jordanHead.faceFeature = feature
        jordanHead.rect = drawRect
        return jordanHead
    }
    
    private class func getRectForDrawingHead(detectedFace: CIFaceFeature, image: UIImage) -> CGRect {
        var transform = CGAffineTransformMakeScale(1, -1)
        transform = CGAffineTransformTranslate(transform, 0, -image.size.height)
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
}
