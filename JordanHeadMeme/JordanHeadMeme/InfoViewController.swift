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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                let debug = UIApplication.shared().isDebugMode ? "DEBUG" : ""
                versionLabel.text = "© David Okun, 2016, v\(version)-\(build)\(debug)"
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.logCustomEventWithName("Info View Shown", customAttributes:nil)
    }

    // MARK: IBAction functions
    
    @IBAction func githubIconTapped() {
        Analytics.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Github"])
        open(urlString: "https://www.github.com/dokun1/jordan-meme-ios")
    }
    
    @IBAction func twitterIconTapped() {
        Analytics.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Twitter"])
        open(urlString: "https://www.twitter.com/dokun24")
    }
    
    @IBAction func instagramIconTapped() {
        Analytics.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Instagram"])
        open(urlString: "https://www.instagram.com/dokun1")
    }
    
    @IBAction func internetIconTapped() {
        Analytics.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Website"])
        open(urlString: "http://okun.io")
    }
    
    @IBAction func reviewButtonTapped() {
        Analytics.logCustomEventWithName("Social Link Tapped", customAttributes:["Site Loaded":"Review"])
        open(urlString: "itms-apps://itunes.apple.com/app/id1084796562")
    }
    
    @IBAction func goBackButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: URL Handler
    
    func open(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared().openURL(url)
        }
    }
}
