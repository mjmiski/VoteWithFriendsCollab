//
//  AppDelegate.swift
//  RealmTasks
//
//  Created by Hossam Ghareeb on 10/12/15.
//  Copyright © 2015 Hossam Ghareeb. All rights reserved.
//

import UIKit
import RealmSwift


var uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        
            // Authenticating the User
            //let username = "matt@matt.com"
            //let password = "Psmor0xx"
            //SyncUser.logInWithCredentials(SyncCredentials.usernamePassword(username, password: password), authServerURL: NSURL(string: "http://emmabiz.com:9080")!, onCompletion:
            //    { user, error in
            //        if let user = user {
            //            // Opening a remote Realm
            //            let realmURL = NSURL(string: "realm://emmabiz.com:9080/~/VWF4")!
            //            let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: realmURL))
                        
            //            Realm.Configuration.defaultConfiguration = config
                        
            //            let uiRealm = try! Realm(configuration: config)
                        
                        // Any changes made to this Realm will be synced across all devices!
            //        } else if let error = error {
                        // handle error
            //        }
            //})
        
       
        
        
        
        
        // Override point for customization after application launch.

        //FB Code
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        func prefersStatusBarHidden() -> Bool {
            return true
        }
        
        let navBackgroundImage:UIImage! = UIImage(named: "backgroundNB.png")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, forBarMetrics: .Default)
        
        return true
    }
    
    //FB Add
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //Added Section for SLider START
    
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
        
        FBSDKAppEvents.activateApp()
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Added Section for SLider END

    
    
}
