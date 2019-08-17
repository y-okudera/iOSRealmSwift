//
//  RealmInitializeService.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmInitializeService {
    var configuration: Realm.Configuration? { get }
    func initializeRealm() -> Realm
    static func defaultConfiguration() -> Realm.Configuration
    static func encryptionKey() -> Data?
}
