//
//  ViewController.swift
//  SDKSample
//
//  Copyright © 2018 Talkdesk. All rights reserved.
//

import UIKit
import TalkdeskSDK

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = InteractionViewController(intention: "callback")
        addChild(vc)
        view.addSubview(vc.view)
    }
}

