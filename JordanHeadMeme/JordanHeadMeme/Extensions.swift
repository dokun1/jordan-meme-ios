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
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clear()
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
        return CGPoint(x: x, y: y)
    }
}

extension CIFaceFeature {
    var faceCentroid: CGPoint {
        var center = self.bounds.rectCenter
        var numberOfEyesDetected = 0
        if self.hasRightEyePosition {
            numberOfEyesDetected += 1
        }
        if self.hasLeftEyePosition {
            numberOfEyesDetected += 1
        }
        let eyeCenter = CGPoint(x: (self.leftEyePosition.x + self.rightEyePosition.x) / CGFloat(numberOfEyesDetected), y: (self.leftEyePosition.y + self.rightEyePosition.y) / CGFloat(numberOfEyesDetected))
        if eyeCenter.equalTo(CGPoint.zero) {
            center.x = (center.x + eyeCenter.x * 3) / 4
            center.y = (center.y + eyeCenter.y * 3) / 4
        }
        
        return center
    }
}

extension UIApplication {
    var isDebugMode: Bool {
        let dictionary = ProcessInfo.processInfo.environment
        return dictionary["DEBUGMODE"] != nil
    }
}

extension UIView {
    func convertToImage(_ imageSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let newImage = UIImage.init(data: UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext()!, 1.0)!) {
            UIGraphicsEndImageContext()
            return newImage
        } else {
            return nil
        }        
    }
}

extension UIImage {
    func drawRectangle(_ bounds: CGRect, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: CGPoint.zero)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(3)
            color.setStroke()
            context.stroke(bounds)
            if let returnedImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return returnedImage
            } else {
                UIGraphicsEndImageContext()
                return self
            }
        } else {
            return self
        }
    }
    
    func resize(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    var fixOrientation: UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch (self.imageOrientation) {
        case .down:
            transform = transform.translateBy(x: self.size.width, y: self.size.width)
            transform = transform.rotate(CGFloat(M_PI))
            break
        case .downMirrored:
            transform = transform.translateBy(x: self.size.width, y: self.size.width)
            transform = transform.rotate(CGFloat(M_PI))
            break
        case .left:
            transform = transform.translateBy(x: self.size.width, y: 0)
            transform = transform.rotate(CGFloat(M_PI_2))
            break
        case .leftMirrored:
            transform = transform.translateBy(x: self.size.width, y: 0)
            transform = transform.rotate(CGFloat(M_PI_2))
            break
        case .right:
            transform = transform.translateBy(x: 0, y: self.size.height)
            transform = transform.rotate(CGFloat(-M_PI_2))
            break
        case .rightMirrored:
            transform = transform.translateBy(x: 0, y: self.size.height)
            transform = transform.rotate(CGFloat(-M_PI_2))
            break
        case .up:
            break
        case .upMirrored:
            break
        }
        
        switch (self.imageOrientation) {
            
        case .upMirrored:
            transform = transform.translateBy(x: self.size.width, y: 0)
            transform = transform.scaleBy(x: -1, y: 1)
            break;
        case .downMirrored:
            transform = transform.translateBy(x: self.size.width, y: 0)
            transform = transform.scaleBy(x: -1, y: 1)
            break;
        case .leftMirrored:
            transform = transform.translateBy(x: self.size.height, y: 0)
            transform = transform.scaleBy(x: -1, y: 1)
            break
        case .rightMirrored:
            transform = transform.translateBy(x: self.size.height, y: 0)
            transform = transform.scaleBy(x: -1, y: 1)
            break
        case .up:
            break
        case .right:
            break
        case .down:
            break
        case .left:
            break
        }
        
        if let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (self.cgImage?.colorSpace!)!, bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!) {
            context.concatCTM(transform)
            
            switch (self.imageOrientation) {
            case .left:
                context.draw(in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width), image: self.cgImage!)
                break
            case .leftMirrored:
                context.draw(in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width), image: self.cgImage!)
                break
            case .right:
                context.draw(in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width), image: self.cgImage!)
                break
            case .rightMirrored:
                context.draw(in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width), image: self.cgImage!)
                break
            default:
                context.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), image: self.cgImage!)
                break
            }
            
            if let cgImage = context.makeImage() {
                return UIImage.init(cgImage: cgImage)
            } else {
                return self
            }
        } else {
            return self
        }
    }
}
