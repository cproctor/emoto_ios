//
//  AppDelegate.swift
//  Emoto
//
//  Created by Chris Proctor on 4/27/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Seed random number generator
        Flurry.startSession("89W9MCKHBC9QR9QDK6ZY");
        Flurry.logEvent("Onboard:Begin")
        
        if(UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        }
        
        // Set up the app to fetch messages in the background.
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        srandom(arc4random())
        return true
    }
    
    // This is the application invocation for background execution.
    // Fetches messages. If there's something new from partner, issues a notification.
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let username = defaults.objectForKey("username") as? String else { return }
        EmotoAPI.getMessagesWithCompletion(username, messageCompletion: nil) { (messages, error) -> Void in
            guard error == nil else { return }
            let partnerMessages = messages!.filter({$0.author != username})
            guard let lastPartnerMessage = partnerMessages.last else { return }
            let latestMessageTimestamp = lastPartnerMessage.timestamp
            if let lastMessageTimestamp = defaults.objectForKey("lastMessageTimestamp") as? NSDate {
                if latestMessageTimestamp.isGreaterThanDate(lastMessageTimestamp) {
                    Flurry.logEvent("Stream:NewMessageNotification")
                    let localNotification = UILocalNotification()
                    localNotification.fireDate = nil
                    localNotification.alertBody = "New Emoto!"
                    localNotification.timeZone = NSTimeZone.defaultTimeZone()
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
            }
            defaults.setObject(latestMessageTimestamp, forKey: "lastMessageTimestamp")
        }
        //return UIBackgroundFetchResult.NewData
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

