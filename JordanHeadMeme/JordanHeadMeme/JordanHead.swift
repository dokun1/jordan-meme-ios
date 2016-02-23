//
//  JordanHead.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/19/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import Foundation
import UIKit

class JordanHead: NSObject {
    var id = Int()
    var facingRight = true
    var faceFeature = CIFaceFeature()
    var rect = CGRect()
    
    var transformedLeftEyePosition: CGPoint {
        let transform = CGAffineTransformMakeScale(1, -1)
        return CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform)
//        let x = faceFeature.leftEyePosition.x
//        let factor = (faceFeature.bounds.size.height / 2) - faceFeature.leftEyePosition.y
//        let y = (faceFeature.bounds.size.height / 2) + (factor * -1)
//        return CGPointMake(x, y)
        
        /* // Create the image and detector
        CIImage* image = [CIImage imageWithCGImage:imageView.image.CGImage];
        CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
        context:... options:...];
        
        // CoreImage coordinate system origin is at the bottom left corner
        // and UIKit is at the top left corner. So we need to translate
        // features positions before drawing them to screen. In order to do
        // so we make an affine transform
        CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
        transform = CGAffineTransformTranslate(transform,
        0, -imageView.bounds.size.height);
        
        // Get features from the image
        NSArray* features = [detector featuresInImage:image];
        for(CIFaceFeature* faceFeature in features) {
        
        // Get the face rect: Convert CoreImage to UIKit coordinates
        const CGRect faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        
        // create a UIView using the bounds of the face
        UIView* faceView = [[UIView alloc] initWithFrame:faceRect];
        
        ...
        
        if(faceFeature.hasLeftEyePosition) {
        
        // Get the left eye position: Convert CoreImage to UIKit coordinates
        const CGPoint leftEyePos = CGPointApplyAffineTransform(faceFeature.leftEyePosition, transform);
        ...
        
        }
        
        ...
        }*/
    }
    
    var transformedRightEyePosition: CGPoint {
        let x = faceFeature.rightEyePosition.x
        let factor = (faceFeature.bounds.size.height / 2) - faceFeature.rightEyePosition.y
        let y = (faceFeature.bounds.size.height / 2) + (factor * -1)
        return CGPointMake(x, y)
    }
    
    var transformedMouthEyePosition: CGPoint {
        let x = faceFeature.mouthPosition.x
        let factor = (faceFeature.bounds.size.height / 2) - faceFeature.mouthPosition.y
        let y = (faceFeature.bounds.size.height / 2) + (factor * -1)
        return CGPointMake(x, y)
    }
    
    override var description: String {
        return "id: \(id), rect: \(NSStringFromCGRect(rect))"
    }
}
