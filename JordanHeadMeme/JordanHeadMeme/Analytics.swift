//
//  Analytics.swift
//  JordanHeadMeme
//
//  Created by David Okun on 22/02/2016.
//  Copyright © 2016 David Okun, LLC. All rights reserved.
//

import Foundation
import UIKit
import Fabric
import Crashlytics

class Analytics: NSObject {
    class func logCustomEventWithName(_ eventName: String!, customAttributes: Dictionary <String, AnyObject>!) {
        if UIApplication.shared().isDebugMode {
            print("EVENT LOGGED: \(eventName) WITH ATTRIBUTES: \(customAttributes)")
            return
        } else {
            Answers.logCustomEvent(withName: eventName, customAttributes: customAttributes)
        }
    }
}
