//
//  Realm+WriteAsync.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2019/08/12.
//  Copyright © 2019 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {

    typealias ErrorHandler = (_ error : Swift.Error) -> Void

    func writeAsync<T: ThreadConfined>(obj: T, errorHandler: @escaping ErrorHandler = { _ in return },
                                       block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: Bundle.main.bundleIdentifier! + ".realm").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}
