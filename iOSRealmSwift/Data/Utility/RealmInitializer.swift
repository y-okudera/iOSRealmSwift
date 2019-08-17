//
//  RealmInitializer.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmInitializer: RealmInitializeService {

    let configuration: Realm.Configuration?

    init(configuration: Realm.Configuration? = defaultConfiguration()) {
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

extension RealmInitializer {

    static func defaultConfiguration() -> Realm.Configuration {
        let configuration = Realm.Configuration(encryptionKey: encryptionKey(),
                                                schemaVersion: RealmMigrator.version,
                                                migrationBlock: RealmMigrator.migrationBlock())
        return configuration
    }

    /// 暗号化キーを取得する
    static func encryptionKey() -> Data? {
        let keyString = "ssuMMd3a97IIGbGxF4kLP6y0Vf723qklg8IaIZHEQgUNnb9lE1W1wx4nlLCgQa0p"
        let keyData = keyString.data(using: .utf8)

        #if DEBUG
        print("encryptionKey -> " + keyData!.map { String(format: "%.2hhx", $0) }.joined())
        #endif

        return keyData
    }
}
