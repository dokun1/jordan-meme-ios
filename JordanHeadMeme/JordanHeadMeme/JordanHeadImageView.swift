//
//  JordanHeadImageView.swift
//  JordanHeadMeme
//
//  Created by David Okun on 2/16/16.
//  Copyright © 2016 David Okun, LLC. All rights reserved.
//

import UIKit

class JordanHeadImageView: UIImageView {
    var referenceHead = JordanHead()
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(head: JordanHead) {
        super.init(frame:head.rect)
        referenceHead = head
        self.image = UIImage.init(named: "jordanHead.png")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var leftEyePosition: CGPoint {
        let multiplier = CGFloat(referenceHead.facingRight ? 1 : -1)
        let x = CGFloat(referenceHead.rect.rectCenter.x + (0.099 * multiplier))
        let y = CGFloat(referenceHead.rect.size.height * 0.468)
        return CGPointMake(x, y)
    }
    
    var rightEyePosition: CGPoint {
        let multiplier = CGFloat(referenceHead.facingRight ? 1 : -1)
        let x = CGFloat(referenceHead.rect.rectCenter.x + (0.405 * multiplier))
        let y = CGFloat(referenceHead.rect.size.height * 0.448)
        return CGPointMake(x, y)
    }
    
    var mouthCenterPosition: CGPoint {
        let multiplier = CGFloat(referenceHead.facingRight ? 1 : -1)
        let x = CGFloat(referenceHead.rect.rectCenter.x + (0.303 * multiplier))
        let y = CGFloat(referenceHead.rect.size.height * 0.448)
        return CGPointMake(x, y)
    }
}