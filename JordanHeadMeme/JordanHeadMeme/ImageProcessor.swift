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
    
    class func rectInImage(_ imageSize: CGSize) -> CGRect {
        return CGRect.null
    }

    class func processImage(_ image: UIImage) -> [JordanHead]?  {
        let ciImage = CIImage(cgImage: image.cgImage!)
        let results = getFaceDetector().features(in: ciImage)
        var counter = 0
        var generatedHeads: [JordanHead] = [JordanHead]()
        for result in results {
            counter += 1
            let face: CIFaceFeature = result as! CIFaceFeature
            if face.hasLeftEyePosition && face.hasRightEyePosition && face.hasMouthPosition {
                let jordanHead = drawJordanHead(getRectForDrawingHead(face, image: image), feature: face, tag: counter)
                generatedHeads.append(jordanHead)
            }
        }
        return generatedHeads
    }
    
    // MARK : Private processing functions
    
    private class func getFaceDetector() -> CIDetector {
        return CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
    }
    
    private class func drawJordanHead(_ drawRect: CGRect, feature: CIFaceFeature, tag: Int) -> JordanHead {
        let jordanHead = JordanHead()
        let jordanHeadImage = UIImageView.init(image: UIImage.init(named: "jordanHead.png"))
        jordanHeadImage.frame = drawRect
        jordanHeadImage.contentMode = .scaleAspectFit
        jordanHeadImage.backgroundColor = UIColor.clear()
        if feature.hasRightEyePosition && feature.hasLeftEyePosition {
            if feature.rightEyePosition.y > feature.leftEyePosition.y {
                jordanHeadImage.transform = CGAffineTransform(scaleX: -1, y: 1)
                jordanHead.facingRight = true
            } else {
                jordanHead.facingRight = false
            }
        }
        jordanHeadImage.transform = CGAffineTransform(rotationAngle: CGFloat(feature.faceAngle * Float(M_PI/180)))
        jordanHeadImage.isUserInteractionEnabled = true
        jordanHeadImage.tag = tag
        jordanHead.id = tag
        jordanHead.faceFeature = feature
        jordanHead.rect = drawRect
        return jordanHead
    }
    
    private class func getRectForDrawingHead(_ detectedFace: CIFaceFeature, image: UIImage) -> CGRect {
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translateBy(x: 0, y: -image.size.height)
        var faceRect = detectedFace.bounds.apply(transform: transform)
        if detectedFace.hasLeftEyePosition && detectedFace.hasRightEyePosition {
            let higherPoint = (detectedFace.leftEyePosition.y > detectedFace.rightEyePosition.y ? detectedFace.leftEyePosition : detectedFace.rightEyePosition)
            let alteredPoint  = higherPoint.apply(transform: transform)
            let centerPoint = faceRect.rectCenter
            let distance = 3.14 * abs(centerPoint.y - alteredPoint.y)
            let alteredDistance = (faceRect.origin.y + faceRect.size.height) - (alteredPoint.y - distance)
            faceRect = CGRect(x: faceRect.origin.x, y: alteredPoint.y - distance, width: faceRect.size.width, height: alteredDistance)
        }
        return faceRect
    }
}
