//
//  RealmMigrator.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmMigrator {

    // リリース時にマイグレーションが必要な場合は、versionをインクリメントする
    static let version: UInt64 = 2

    /// Realmのマイグレーションオブジェクトを取得する
    static func migrationBlock() -> MigrationBlock? {

        return { migration, oldSchemaVersion in

            if oldSchemaVersion < 1 {

                migration.deleteData(forType: TaskEntity.className())

                // データベース内にある全てのFolderEntityモデルを列挙
                migration.enumerateObjects(ofType: FolderEntity.className(), { oldObject, newObject in

                    guard let oldObject = oldObject, let newObject = newObject else {
                        return
                    }

                    // 旧バージョンのフォルダに紐づくタスクを取得して、limitDateが設定されていて、且つ超過していないデータだけ新バージョンに移行する
                    let oldTaskList = oldObject["taskList"] as! List<MigrationObject>
                    let taskList = newObject["taskList"] as! List<MigrationObject>

                    for oldTask in oldTaskList {
                        let newTaskDic = oldTask.dictionaryWithValues(forKeys: ["taskId", "title", "limitDate", "isDone"])

                        if let limitDate = newTaskDic["limitDate"] as? Date {
                            if limitDate > Date() {
                                let newTaskList = migration.create(TaskEntity.className(), value: newTaskDic)
                                taskList.append(newTaskList)
                            }
                        }
                    }
                })

                // データベース内にある全てのTaskEntityモデルを列挙
                migration.enumerateObjects(ofType: TaskEntity.className(), { oldObject, newObject in
                    // 古いオブジェクトからtitleを取得
                    let oldTitle = oldObject!["title"] as! String
                    // 新しいオブジェクトのtitleに新しい値を設定
                    newObject?["title"] = "[UPDATED]\(oldTitle)"
                })
            }

            if oldSchemaVersion < 2 {
                // 何もしないマイグレーション
            }
        }
    }
}

extension RealmMigrator {
    static func migrate(service: RealmInitializeService = RealmInitializer()) {
        let realm = service.initializeRealm()
        print("schemaVersion", realm.configuration.schemaVersion)
    }
}
