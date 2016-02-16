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
}