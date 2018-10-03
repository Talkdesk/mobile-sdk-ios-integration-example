//
//  AppDelegate.swift
//  SDKSample
//
//  Copyright © 2018 Talkdesk. All rights reserved.
//

import UIKit
import TalkdeskSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authorizationController = AuthorizationController()

    func applicationDidFinishLaunching(_ application: UIApplication) {
        TalkdeskSDK.authorizationDelegate = authorizationController
    }
}
