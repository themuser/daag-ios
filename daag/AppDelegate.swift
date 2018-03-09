//
//  AppDelegate.swift
//  SDS Campus Menu
//
//  Created by Myungkyo Jung on 5/16/15.
//  Copyright (c) 2015 Myungkyo Jung. All rights reserved.
//

import UIKit
import HealthKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        Fabric.with([Crashlytics.self])

        // healthkit integration
        _ = HKHealthStore()
        
//        let healthKitTypesToRead = NSSet(array: [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)]) as Set<NSObject>
//        let healthKitTypesToWrite = NSSet(array: [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)])  as Set<NSObject>
//        
//        if !HKHealthStore.isHealthDataAvailable(){
//            let error = NSError(domain: "io.myungkyo.daag", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
//        }
//        
//        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil
//            , completion: {(success, error) -> Void in
//            }
//        )

        
        // push notification
        //        if application.respondsToSelector("isRegisteredForRemoteNotifications"){
        //            // iOS 8 Notifications
        //            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: (.Badge | .Sound | .Alert), categories: nil));
        //            application.registerForRemoteNotifications()
        //
        //        } else {
        //            // iOS < 8 Notifications
        ////            application.registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)
        //        }
        
        
        return true
    }
    
    //    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    //        println("###############################################")
    //        println("device token: \(deviceToken)")
    //    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

