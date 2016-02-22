//
//  AppDelegate.swift
//  JordanHeadMeme
//
//  Created by David Okun on 12/18/15.
//  Copyright © 2015 David Okun, LLC. All rights reserved.
//

import UIKit
import SVProgressHUD
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    @available(iOS 9.0, *)
    lazy var shortcutItem: UIApplicationShortcutItem? = {
        return nil
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        SVProgressHUD.setBackgroundColor(UIColor.colorSchemeTwo())
        SVProgressHUD.setForegroundColor(UIColor.colorSchemeOne())
        application.statusBarHidden = true
        var performShortcutDelegate = true
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                self.shortcutItem = shortcutItem
                performShortcutDelegate = false
            }
        }
        if UIApplication.sharedApplication().isDebugMode {
            print("APP LOADED IN DEBUG MODE")
        } else {
            Fabric.with([Answers.self, Crashlytics.self])
        }
        return performShortcutDelegate
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    
    @available(iOS 9.0, *)
    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        var succeeded = true
        let mainViewController = self.window?.rootViewController as! ViewController
        if shortcutItem.type.containsString("takeSelfie") {
            Analytics.logCustomEventWithName("Shortcut Used", customAttributes: ["Method":"Take Selfie"])
            mainViewController.takeSelfieTapped()
        } else if shortcutItem.type.containsString("choosePhoto") {
            Analytics.logCustomEventWithName("Shortcut Used", customAttributes: ["Method":"Choose Photo"])
            mainViewController.choosePhotoTapped()
        } else if shortcutItem.type.containsString("takePhoto") {
            Analytics.logCustomEventWithName("Shortcut Used", customAttributes: ["Method":"Take Photo"])
            mainViewController.takePhotoTapped()
        } else {
            succeeded = false
        }
        return succeeded
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

