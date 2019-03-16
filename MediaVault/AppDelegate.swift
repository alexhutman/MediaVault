//
//  AppDelegate.swift
//  MediaVault
//
//  Created by alex on 2/28/18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit
import CoreData
import SQLite

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("RECEIVED DB FILE IN \(url.path)")
        do {
            let defaultDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let metadataDbURL = defaultDir.appendingPathComponent("metadata").appendingPathExtension("db")
            let dbName = url.lastPathComponent.components(separatedBy: ".")[0]
            let dbURL = defaultDir.appendingPathComponent("userDBs").appendingPathComponent(dbName).appendingPathExtension("db")
            print("DB NAME: \(dbName)")
            
            try FileManager.default.copyItem(at: url, to: dbURL)
            try FileManager.default.removeItem(at: url)
            
            let metadataTable = Table("metadata")
            let metadataID = Expression<String>("id")
            let metadataLastTime = Expression<String>("lastTime")
            let metadataLastLoc = Expression<String>("lastLoc")
            
            let metadataDB = try Connection(metadataDbURL.path)
            let insertDBNameToMetadataDB = metadataTable.insert(metadataID <- dbName, metadataLastLoc <- "-", metadataLastTime <- "-")
            try metadataDB.run(insertDBNameToMetadataDB)
            let homePageVC = self.window?.rootViewController?.childViewControllers[0] as! HomePageViewController
            homePageVC.handleOpenURL()
            
            return true
        } catch {
            //TODO: ALERT, COULDNT OPEN FILE
            print(error)
            return false
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.black
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark) //This code was from https://stackoverflow.com/questions/31982270/blurring-app-screen-in-switch-mode-on-ios
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = 221122
        
        self.window?.addSubview(blurEffectView)
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
        self.window?.viewWithTag(221122)?.removeFromSuperview()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MediaVault")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

