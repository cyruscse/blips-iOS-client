//
//  AppDelegate.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-10-26.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, LookupModelObserver {
    var window: UIWindow?
    private var mainVC: ViewController!

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // 120 for withDimension matches the width of the UIImageView used for the picture
            // Try to set this as a constant, or maybe pull the value from IB
            // On login, set user ID as 0, and give an empty dictionary for atttraction history
            // These values will be retrieved from the server after the User object is created
            let account = User(firstName: user.profile.givenName, lastName: user.profile.familyName, imageURL: user.profile.imageURL(withDimension: 240), email: user.profile.email, userID: 0, attractionHistory: [:], guest: false)
            
            mainVC.relayUserLogin(account: account)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Init Google Sign-in
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if let rootViewController = window?.rootViewController as? UINavigationController {
            if let viewController = rootViewController.viewControllers.first as? ViewController {
                self.mainVC = viewController
                mainVC.relayAppDelegateLookupModelObserverAddition(observer: self)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String]) {}
    
    func gotGoogleClientKey(key: String) {
        GMSPlacesClient.provideAPIKey(key)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

