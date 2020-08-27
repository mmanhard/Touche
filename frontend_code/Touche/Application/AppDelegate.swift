//
//  AppDelegate.swift
//  Touche
//
//  Created by Michael Manhard on 5/6/15.
//  Copyright (c) 2015 Michael Manhard. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
      return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
}

