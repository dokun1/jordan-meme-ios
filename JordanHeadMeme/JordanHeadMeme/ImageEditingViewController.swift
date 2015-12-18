//
//  ImageEditingViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
import QuartzCore

extension UIImage {
    
    var fixOrientation: UIImage {
        if self.imageOrientation == .Up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch (self.imageOrientation) {
            case .Down:
                transform = CGAffineTransformTranslate(transform, self.size.width, self.size.width)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
                break
            case .DownMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, self.size.width)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
                break
            case .Left:
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
                break
            case .LeftMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
                break
            case .Right:
                transform = CGAffineTransformTranslate(transform, 0, self.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
                break
            case .RightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, self.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
                break
            case .Up:
                break
            case .UpMirrored:
                break
        }
        
        switch (self.imageOrientation) {
            
        case .UpMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break;
        case .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break;
        case .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .Up:
            break
        case .Right:
            break
        case .Down:
            break
        case .Left:
            break
        }

        let context = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue)
        CGContextConcatCTM(context, transform)
        
        switch (self.imageOrientation) {
            case .Left:
                CGContextDrawImage(context, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
                break
            case .LeftMirrored:
                CGContextDrawImage(context, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
                break
            case .Right:
                CGContextDrawImage(context, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
                break
            case .RightMirrored:
                CGContextDrawImage(context, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
                break
            default:
                CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage)
                break
        }
        
        let cgImage = CGBitmapContextCreateImage(context)
        let uiImage = UIImage.init(CGImage: cgImage!)
        
        return uiImage
    }
}

class ImageEditingViewController: UIViewController {
    var uneditedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        imageView.image = uneditedImage.fixOrientation
    }
    
    override func viewDidAppear(animated: Bool) {
        if let results = processImage() {
            for r in results {
                let face:CIFaceFeature = r as! CIFaceFeature
                print(face.bounds)
            }
        }
    }
    
    func processImage() -> NSArray? {
        if let image = uneditedImage {
            let ciImage = CIImage(CGImage: image.fixOrientation.CGImage!)
            return getFaceDetector().featuresInImage(ciImage)
        } else {
            return nil
        }
    }

    func getFaceDetector() -> CIDetector {
        return CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
    }
    
}
