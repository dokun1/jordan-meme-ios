//
//  Extensions.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/19/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension String {
    var hexColor: UIColor {
        let hex = self.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clearColor()
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIColor {
    class func colorSchemeOne() -> UIColor {
        let hexCode = "1E152A"
        return hexCode.hexColor
    }
    
    class func colorSchemeTwo() -> UIColor {
        let hexCode = "63CCCA"
        return hexCode.hexColor
    }
    
    class func colorSchemeThree() -> UIColor {
        let hexCode = "4E6766"
        return hexCode.hexColor
    }
    
    class func colorSchemeFour() -> UIColor {
        let hexCode = "42858C"
        return hexCode.hexColor
    }
    
    class func colorSchemeFive() -> UIColor {
        let hexCode = "35393C"
        return hexCode.hexColor
    }
}

extension CGRect {
    var rectCenter: CGPoint {
        let x = self.origin.x + (self.size.width / 2)
        let y = self.origin.y + (self.size.height / 2)
        return CGPointMake(x, y)
    }
}

extension CIFaceFeature {
    var faceCentroid: CGPoint {
        var center = self.bounds.rectCenter
        var numberOfEyesDetected = 0
        if self.hasRightEyePosition {
            numberOfEyesDetected++
        }
        if self.hasLeftEyePosition {
            numberOfEyesDetected++
        }
        let eyeCenter = CGPointMake((self.leftEyePosition.x + self.rightEyePosition.x) / CGFloat(numberOfEyesDetected), (self.leftEyePosition.y + self.rightEyePosition.y) / CGFloat(numberOfEyesDetected))
        if CGPointEqualToPoint(eyeCenter, CGPointZero) {
            center.x = (center.x + eyeCenter.x * 3) / 4
            center.y = (center.y + eyeCenter.y * 3) / 4
        }
        
        return center
    }
}

extension UIApplication {
    var isDebugMode: Bool {
        let dictionary = NSProcessInfo.processInfo().environment
        return dictionary["DEBUGMODE"] != nil
    }
}

extension UIView {
    func convertToImage(imageSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIImage.init(data: UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 1.0)!)
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIImage {
    func drawRectangle(bounds: CGRect, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.drawAtPoint(CGPointZero)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 3)
        color.setStroke()
        CGContextStrokeRect(context, bounds)
        let returnedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnedImage
    }
    
    func resize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
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
