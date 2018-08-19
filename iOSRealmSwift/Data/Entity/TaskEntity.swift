//
//  TaskEntity.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/17.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class TaskEntity: Object {

    @objc dynamic var taskId = 1
    @objc dynamic var title = ""
    @objc dynamic var limitDate: Date?
    @objc dynamic var isDone = false

    override static func primaryKey() -> String? {
        return "taskId"
    }

    /*
     RealmSwift.Objectを継承したモデルクラスにInitializerを追加する場合はConvenience Initializerを実装する
     （Object.init()のoverrideはサポートされていないため）
     */
    convenience init(taskId: Int = 1, title: String, limitDate: Date?, isDone: Bool = false) {
        self.init()
        self.taskId = taskId
        self.title = title
        self.limitDate = limitDate
        self.isDone = isDone
    }
}
