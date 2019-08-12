//
//  RealmMigrator.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import RealmSwift

final class RealmMigrator {

    /// Realmのマイグレーション
    ///
    /// リリース時にマイグレーションが必要な場合は、newSchemaVersionをインクリメントする
    ///
    /// - Parameters:
    ///   - newSchemaVersion: 新しいスキーマバージョン
    ///   - configuration: Realmコンフィグレーション
    static func migrate(newSchemaVersion: UInt64, configuration: Realm.Configuration? = nil) {

        var configuration = configuration ?? Realm.Configuration()

        /// SchemaVersion1更新フラグ
        var needsMigrationToV1 = false

        configuration.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // データベース内にある全てのTaskEntityモデルを列挙
                migration.enumerateObjects(ofType: TaskEntity.className(), { oldObject, newObject in

                    // 古いオブジェクトからtitleを取得
                    let oldTitle = oldObject!["title"] as! String

                    // 新しいオブジェクトのtitleに新しい値を設定
                    newObject?["title"] = "[UPDATED]\(oldTitle)"
                })

                needsMigrationToV1 = true
            }

            if oldSchemaVersion < 2 {
                // 何もしないマイグレーション
            }
        }

        // スキーマバージョンを設定（デフォルト値は0）
        configuration.schemaVersion = newSchemaVersion
        configuration.encryptionKey = RealmInitializer.encryptionKey()

        let realmInitializer = RealmInitializer(configuration: configuration)
        let realm = realmInitializer.initializeRealm()
        print("Realm SchemaVersion: \(realm.configuration.schemaVersion)")

        // migrationブロックではListTypeのマイグレーションができないため、通常のRealmAPIを使用してマイグレーションを実行する
        if needsMigrationToV1 {
            // 全てのFolderEntityのうち、taskListが0件のレコードを削除する
            let allFolders = realm.objects(FolderEntity.self)
            do {
                try realm.write {
                    for folder in allFolders where folder.taskList.count == 0 {
                        realm.delete(folder)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
