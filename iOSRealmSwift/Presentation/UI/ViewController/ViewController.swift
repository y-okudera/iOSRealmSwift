//
//  ViewController.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/17.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 非同期でDBを更新する動作確認
        addTask100()
        asyncUpdate(taskId: 100)

        // マイグレーションの動作確認用のデータ登録
        // 登録後、RealmMigratorのバージョンをあげて、起動するとマイグレーションする
//        let task1 = TaskEntity(taskId: 1, title: "タスク1", limitDate: nil)
//        let task2 = TaskEntity(taskId: 2, title: "タスク2", limitDate: Date(timeInterval: TimeInterval(60 * 60 * 24 * -7), since: Date()))
//        let task3 = TaskEntity(taskId: 3, title: "タスク3", limitDate: Date(timeInterval: TimeInterval(60 * 60 * 24 * 7), since: Date()))
//
//        let dao = FolderDao()
//        let folder = FolderEntity(folderId: 1, title: "データあり", lastUpdated: Date(), taskList: [task1, task2, task3])
//        let emptyFolder = FolderEntity(folderId: 2, title: "データなし", lastUpdated: Date())
//        dao.add(entity: folder)
//        dao.add(entity: emptyFolder)
    }

    // 100件DBに追加する
    func addTask100() {
        let dao = TaskDao()

        for i in 0..<100 {
            print("i: \(i)")
            let task = TaskEntity(taskId: 100 + i, title: "\(i)", limitDate: nil)
            dao.add(entity: task)
        }
    }

    // タスクIDを指定して、メインスレッド・サブスレッド両方で更新をする
    func asyncUpdate(taskId: Int) {

        let daoHelper = RealmDaoHelper<TaskEntity>()
        print("\(daoHelper.realm.configuration.fileURL?.absoluteString ?? "")")

        // 更新対象のデータ(Managed object)を取得
        guard let task = daoHelper.findById(id: taskId as AnyObject) else {
            return
        }

        daoHelper.realm.writeAsync(obj: task) { realm, taskObj in
            guard let taskObj = taskObj else {
                return
            }
            // データ更新
            taskObj.title = "[background updated]" + taskObj.title
            taskObj.isDone = true
        }
        // Main Thread
        do {
            try daoHelper.realm.write {
                // データ更新
                task.title = "hoooo"
            }
        }
        catch {
            print(error)
        }
    }
}
