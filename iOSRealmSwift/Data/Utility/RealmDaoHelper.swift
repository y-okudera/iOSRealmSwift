//
//  RealmDaoHelper.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmDaoHelper <T: RealmSwift.Object> {

    var realm: Realm

    init(service: RealmInitializer = RealmInitializer()) {
        self.realm = service.initializeRealm()
    }

    // MARK: - Create a new primary key

    /// 新規主キー発行
    func newId() -> Int? {
        guard let key = T.primaryKey() else {
            // primaryKey未設定
            return nil
        }
        return (realm.objects(T.self).max(ofProperty: key) as Int? ?? 0) + 1
    }

    // MARK: - Add record

    /// レコード追加
    func add(d: T) {
        do {
            try realm.write {
                realm.add(d)
            }
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }

    // MARK: - Update record

    /// T: RealmSwift.Object で primaryKey()が実装されている時のみ有効
    func update(d: T) -> Bool {
        do {
            try realm.write {
                realm.add(d, update: true)
            }
            return true
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        return false
    }

    // MARK: - Delete records

    /// レコード全削除
    func deleteAll() -> Bool {
        let objs = realm.objects(T.self)
        do {
            try realm.write {
                realm.delete(objs)
            }
            return true
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        return false
    }

    /// レコード削除
    func delete(d: T) -> Bool {
        do {
            try realm.write {
                realm.delete(d)
            }
            return true
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        return false
    }

    // MARK: - Find records

    /// 全件取得（Results<T> type）
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }

    /// 全件取得（Array type）
    func findAllConvertedToArray() -> [T] {
        return Array(findAll())
    }

    /// 指定キーのレコードを取得
    func findById(id: AnyObject) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: id)
    }
}
