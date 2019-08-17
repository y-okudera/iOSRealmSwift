//
//  TaskDao.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class TaskDao {

    let daoHelper: RealmDaoHelper<TaskEntity>

    init(dao: RealmDaoHelper<TaskEntity> = RealmDaoHelper<TaskEntity>()) {
        self.daoHelper = dao
    }

    // MARK: - Add

    @discardableResult
    func add(entity: TaskEntity) -> Int {
        let object = TaskEntity(value: entity)
        object.taskId = daoHelper.newId()!
        daoHelper.add(d: object)
        return object.taskId
    }

    // MARK: - Update

    @discardableResult
    func update(entity: TaskEntity) -> Bool {
        if daoHelper.findById(id: entity.taskId as AnyObject) == nil {
            return false
        }
        return daoHelper.update(d: entity)
    }

    // MARK: - Delete

    @discardableResult
    func delete(taskId: Int) -> Bool {
        guard let object = daoHelper.findById(id: taskId as AnyObject) else {
            return false
        }
        return daoHelper.delete(d: object)
    }

    // MARK: - Find

    func findById(taskId: Int) -> TaskEntity? {
        guard let object = daoHelper.findById(id: taskId as AnyObject) else {
            return nil
        }
        return TaskEntity(value: object)
    }
}
