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

    private let dao: RealmDaoHelper<TaskEntity>

    init(dao: RealmDaoHelper<TaskEntity> = RealmDaoHelper<TaskEntity>()) {
        self.dao = dao
    }

    // MARK: - Add

    @discardableResult
    func add(entity: TaskEntity) -> Int {
        let object = TaskEntity(value: entity)
        object.taskId = dao.newId()!
        dao.add(d: object)
        return object.taskId
    }

    // MARK: - Update

    @discardableResult
    func update(entity: TaskEntity) -> Bool {
        if dao.findById(id: entity.taskId as AnyObject) == nil {
            return false
        }
        return dao.update(d: entity)
    }

    // MARK: - Delete

    @discardableResult
    func delete(taskId: Int) -> Bool {
        guard let object = dao.findById(id: taskId as AnyObject) else {
            return false
        }
        return dao.delete(d: object)
    }

    // MARK: - Find

    func findById(taskId: Int) -> TaskEntity? {
        guard let object = dao.findById(id: taskId as AnyObject) else {
            return nil
        }
        return TaskEntity(value: object)
    }
}
