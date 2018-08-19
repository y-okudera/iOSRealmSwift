//
//  RealmInitializer.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import RealmSwift

final class RealmInitializer: RealmInitializeService {
    
    let configuration: Realm.Configuration?

    init(configuration: Realm.Configuration? = nil) {
        self.configuration = configuration
    }

    func initializeRealm() -> Realm {
        do {
            var realm: Realm
            if let configuration = configuration {
                realm = try Realm(configuration: configuration)
            } else {
                realm = try Realm()
            }
            return realm

        } catch {
            fatalError("Realm initialize error: \(error)")
        }
    }
}
