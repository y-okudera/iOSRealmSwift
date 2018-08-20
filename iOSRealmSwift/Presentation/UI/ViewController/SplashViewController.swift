//
//  SplashViewController.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Realm migration
        RealmMigrator.migrate(newSchemaVersion: 2)
        
        guard let vc = UIStoryboard.viewController(
            storyboardName: "Main",
            identifier: "ViewController") as? ViewController else {
                fatalError("ViewController is nil.")
        }
        present(vc, animated: true, completion: nil)
    }
}
