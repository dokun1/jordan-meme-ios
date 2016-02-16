//
//  InfoViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 2/16/16.
//  Copyright © 2016 David Okun, LLC. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics

class InfoViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
                versionLabel.text = "© David Okun, 2016, v\(version)-\(build)"
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logCustomEventWithName("Info View Shown", customAttributes:nil)
    }

    @IBAction func githubIconTapped() {
        Answers.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Github"])
        let url = NSURL.init(string: "https://www.github.com/dokun1/jordan-meme-ios")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func twitterIconTapped() {
        Answers.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Twitter"])
        let url = NSURL.init(string: "https://www.twitter.com/dokun24")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func instagramIconTapped() {
        Answers.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Instagram"])
        let url = NSURL.init(string: "https://www.instagram.com/dokun1")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func internetIconTapped() {
        Answers.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Website"])
        let url = NSURL.init(string: "http://okun.io")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func reviewButtonTapped() {
        Answers.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Review"])
        let url = NSURL.init(string: "itms-apps://itunes.apple.com/app/id1084796562")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func goBackButtonTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
