//
//  RealmInitializerForTest.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift
@testable import iOSRealmSwift

final class RealmInitializerForTest: NSObject {
    static func realmInitializeService(filePath: String = UTFileManager.getUTRealmPath()) -> RealmInitializer {
        let fileURL = URL(fileURLWithPath: filePath)
        
        var configuration: Realm.Configuration? = RealmInitializer.defaultConfiguration()
        configuration?.fileURL = fileURL
        return RealmInitializer(configuration: configuration)
    }
}
