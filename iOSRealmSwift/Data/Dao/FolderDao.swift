//
//  FolderDao.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class FolderDao {

    private let dao: RealmDaoHelper<FolderEntity>
    private let taskDao: TaskDao

    init(daoHelper: RealmDaoHelper<FolderEntity> = RealmDaoHelper<FolderEntity>(),
         taskDaoHelper: RealmDaoHelper<TaskEntity> = RealmDaoHelper<TaskEntity>()) {
        self.dao = daoHelper
        self.taskDao = TaskDao(dao: taskDaoHelper)
    }

    // MARK: - Add

    func add(entity: FolderEntity) {
        let object = FolderEntity(value: entity)
        object.folderId = dao.newId()!
        dao.add(d: object)
    }

    // MARK: - Update

    @discardableResult
    func update(entity: FolderEntity) -> Bool {
        if dao.findById(id: entity.folderId as AnyObject) == nil {
            return false
        }
        return dao.update(d: entity)
    }

    // MARK: - Delete

    @discardableResult
    func deleteAll() -> Bool {
        return dao.deleteAll()
    }

    @discardableResult
    func delete(folderId: Int) -> Bool {
        guard let object = dao.findById(id: folderId as AnyObject) else {
            return false
        }
        return dao.delete(d: object)
    }

    // MARK: - Find

    /// lastUpdatedが近い順で全件取得
    func findAllSortedByLastUpdatedDESC() -> [FolderEntity] {
        let allObjects = dao.findAll().sorted(byKeyPath: "lastUpdated", ascending: false)
        return Array(allObjects)
    }

    func findById(folderId: Int) -> FolderEntity? {
        guard let object = dao.findById(id: folderId as AnyObject) else {
            return nil
        }
        return FolderEntity(value: object)
    }

    // MARK: - Related tables (Task table)

    /// 該当フォルダ内のすべてのTaskを削除
    ///
    /// - Parameter folderId: フォルダID
    func deleteAllTasks(folderId: Int) {

        guard let folder = findById(folderId: folderId) else {
            return
        }
        folder.taskList.forEach {
            taskDao.delete(taskId: $0.taskId)
        }
        let updatedFolder = FolderEntity(
            folderId: folder.folderId,
            title: folder.title,
            lastUpdated: folder.lastUpdated,
            taskList: []
        )
        update(entity: updatedFolder)
    }

    /// 該当フォルダ内のすべてのTaskを取得する
    ///
    /// - Parameter folderId: フォルダID
    /// - Returns: タスク一覧(limitDateが近い順)
    func findAllTasks(folderId: Int) -> [TaskEntity] {

        guard let folder = findById(folderId: folderId) else {
            return []
        }
        let allTasksInFolder = folder.taskList.sorted { $0.limitDate! > $1.limitDate! }
        return Array(allTasksInFolder)
    }
}
