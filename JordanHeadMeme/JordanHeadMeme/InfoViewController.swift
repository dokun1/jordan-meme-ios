//
//  InfoViewController.swift
//  JordanHeadMeme
//
//  Created by David Okun on 2/16/16.
//  Copyright © 2016 David Okun, LLC. All rights reserved.
//

import UIKit
import Foundation

class InfoViewController: UIViewController {

    @IBAction func githubIconTapped() {
        let url = NSURL.init(string: "https://www.github.com/dokun1/jordan-meme-ios")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func twitterIconTapped() {
        let url = NSURL.init(string: "https://www.twitter.com/dokun24")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func instagramIconTapped() {
        let url = NSURL.init(string: "https://www.instagram.com/dokun1")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func internetIconTapped() {
        let url = NSURL.init(string: "http://okun.io")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func reviewButtonTapped() {
        let url = NSURL.init(string: "https://www.github.com/dokun1/jordan-meme-ios")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func goBackButtonTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
