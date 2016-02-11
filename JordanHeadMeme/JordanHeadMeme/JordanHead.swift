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
    
    override var description: String {
        return "id: \(id), rect: \(NSStringFromCGRect(rect))"
    }
}
