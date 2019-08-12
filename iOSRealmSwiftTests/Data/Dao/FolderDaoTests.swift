//
//  FolderDaoTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
@testable import iOSRealmSwift

final class FolderDaoTests: XCTestCase {

    private var folderDaoHelper: RealmDaoHelper<FolderEntity> {
        let service = RealmInitializerForTest.realmInitializeService()
        return RealmDaoHelper<FolderEntity>(service: service)
    }

    private var taskDaoHelper: RealmDaoHelper<TaskEntity> {
        let service = RealmInitializerForTest.realmInitializeService()
        return RealmDaoHelper<TaskEntity>(service: service)
    }

    // MARK: - setUp
    
    override func setUp() {
        super.setUp()
        UTFileManager.removeUTDirectory()
    }

    // MARK: - Test to add record

    /// folderテーブルにレコードを追加するテスト
    func testAdd() {

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)

        // レコード数が0件であることをテスト
        XCTAssertEqual(folderDao.findAllSortedByLastUpdatedDESC().count, 0)

        // レコードを1件追加
        let date = "2018-08-19 11:22:33".toDate()
        addFolder(date: date)

        // レコード数が1件になっていることをテスト
        XCTAssertEqual(folderDao.findAllSortedByLastUpdatedDESC().count, 1)
        // レコードを取得し、検証する
        verifyFolderRecord(folderId: 1, expectedValueOfTitle: "テストフォルダA", expectedValueOfDate: date)
    }

    // MARK: - Test to update record

    /// folderテーブルのレコードを更新するテスト
    func testUpdate() {

        // folderテーブルにレコードを追加する
        testAdd()

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)
        // レコードを取得し、更新する
        if let selectedRecord = folderDao.findById(folderId: 1) {

            let updatedDate = "2018-08-20 11:22:33".toDate()
            selectedRecord.title = "テストフォルダB"
            selectedRecord.lastUpdated = updatedDate
            folderDao.update(entity: selectedRecord)

            // 更新後のレコードを取得し、検証する
            verifyFolderRecord(folderId: 1, expectedValueOfTitle: "テストフォルダB", expectedValueOfDate: updatedDate)
        } else {
            XCTFail("The record not found.")
        }
    }

    // MARK: - Test to delete record

    /// folderテーブルのレコードを削除するテスト
    func testDelete() {

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)

        // レコードを追加
        addFolder(title: "フォルダA", date: "2018-08-19 11:22:33".toDate())
        addFolder(title: "フォルダB", date: "2018-08-20 22:22:33".toDate())
        addFolder(title: "フォルダC", date: "2018-08-21 03:22:33".toDate())

        // レコード数が3件であることをテスト
        XCTAssertEqual(folderDao.findAllSortedByLastUpdatedDESC().count, 3)

        // id1のレコードを削除する
        folderDao.delete(folderId: 1)
        // 削除したレコードが存在しないことをテスト
        XCTAssertNil(folderDao.findById(folderId: 1))
        // レコード数が2件になっていることをテスト
        XCTAssertEqual(folderDao.findAllSortedByLastUpdatedDESC().count, 2)

        // 全てのレコードを削除する
        folderDao.deleteAll()
        // レコード数が0件になっていることをテスト
        XCTAssertEqual(folderDao.findAllSortedByLastUpdatedDESC().count, 0)
    }

    // MARK: - Test to find all record

    /// folderテーブルのレコードをlastUpdatedが近い順で全件取得するテスト
    func testFindAllSortedByLastUpdatedDESC() {

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)

        // レコードを追加
        addFolder(title: "フォルダA", date: "2018-08-19 11:22:33".toDate())
        addFolder(title: "フォルダB", date: "2018-08-20 22:22:33".toDate())
        addFolder(title: "フォルダC", date: "2018-08-21 03:22:33".toDate())
        addFolder(title: "フォルダD", date: "2018-08-23 15:22:33".toDate())
        addFolder(title: "フォルダE", date: "2018-08-22 18:22:33".toDate())

        let allRecords = folderDao.findAllSortedByLastUpdatedDESC()
        
        let expectedValueOfTitles = ["フォルダD", "フォルダE", "フォルダC", "フォルダB", "フォルダA"]
        XCTAssertEqual(allRecords.map { $0.title }, expectedValueOfTitles)
    }

    // MARK: - Test to find nested task list

    /// 該当フォルダに紐づくタスクを取得するテスト
    func testFindNestedTaskList() {
        let theFolder = FolderEntity(title: "テストフォルダA", lastUpdated: "2018-08-19 11:22:33".toDate())
        let taskList = [
            TaskEntity(title: "タスク1", limitDate: "2018-08-30 12:00:00".toDate()),
            TaskEntity(title: "タスク2", limitDate: "2018-08-25 15:00:00".toDate())
        ]

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)
        let taskDao = TaskDao(dao: taskDaoHelper)

        // フォルダを1件追加
        folderDao.add(entity: theFolder)

        taskList.forEach {
            // タスクを追加
            let newTaskId = taskDao.add(entity: $0)
            if
                let folder = folderDao.findById(folderId: 1),
                let task = taskDao.findById(taskId: newTaskId)
            {
                // タスクのレコードをフォルダのレコードに紐づける
                folder.taskList.append(task)
                folderDao.update(entity: folder)
            }
        }

        // id1のレコードに紐づくタスクレコードを取得する
        let allTasksInFolder1 = folderDao.findAllTasks(folderId: 1)

        allTasksInFolder1.enumerated().forEach {
            verifyTaskRecord(
                taskId: $1.taskId,
                expectedValueOfTitle: taskList[$0].title,
                expectedValueOfDate: taskList[$0].limitDate,
                expectedValueOfIsDone: taskList[$0].isDone
            )
        }
    }

    // MARK: - Test to delete nested task list

    /// 該当フォルダに紐づくタスクを全て削除するテスト
    func testDeleteNestedTaskList() {

        // 該当フォルダに紐づくタスクを追加
        let theFolder = FolderEntity(title: "テストフォルダA", lastUpdated: "2018-08-19 11:22:33".toDate())
        let taskList = [
            TaskEntity(title: "タスク1", limitDate: "2018-08-30 12:00:00".toDate()),
            TaskEntity(title: "タスク2", limitDate: "2018-08-25 15:00:00".toDate())
        ]

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)
        let taskDao = TaskDao(dao: taskDaoHelper)

        // フォルダを1件追加
        folderDao.add(entity: theFolder)

        taskList.forEach {
            // タスクを追加
            let newTaskId = taskDao.add(entity: $0)
            if
                let folder = folderDao.findById(folderId: 1),
                let task = taskDao.findById(taskId: newTaskId)
            {
                // タスクのレコードをフォルダのレコードに紐づける
                folder.taskList.append(task)
                folderDao.update(entity: folder)
            }
        }
        
        // id1のレコードに紐づくタスクレコードを全て削除する
        folderDao.deleteAllTasks(folderId: 1)
        // id1のレコードに紐づくタスクレコードを取得する
        let allTasksInFolder1AfterDelete = folderDao.findAllTasks(folderId: 1)
        XCTAssertEqual(allTasksInFolder1AfterDelete.count, 0)
    }

    // MARK: - Private methods

    /// レコードを追加する
    private func addFolder(title: String = "テストフォルダA", date: Date?) {

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)
        let newFolder = FolderEntity(title: title, lastUpdated: date)
        folderDao.add(entity: newFolder)
    }
    
    /// フォルダテーブルのレコードを取得し、検証する
    private func verifyFolderRecord(folderId: Int, expectedValueOfTitle: String, expectedValueOfDate: Date?) {

        let folderDao = FolderDao(daoHelper: folderDaoHelper, taskDaoHelper: taskDaoHelper)
        if let selectedRecord = folderDao.findById(folderId: folderId) {
            XCTAssertEqual(selectedRecord.folderId, folderId)
            XCTAssertEqual(selectedRecord.title, expectedValueOfTitle)
            XCTAssertNotNil(selectedRecord.lastUpdated)
            XCTAssertEqual(selectedRecord.lastUpdated, expectedValueOfDate)
        } else {
            XCTFail("The record not found.")
        }
    }

    /// タスクテーブルのレコードを取得し、検証する
    private func verifyTaskRecord(taskId: Int, expectedValueOfTitle: String, expectedValueOfDate: Date?, expectedValueOfIsDone: Bool) {

        let taskDao = TaskDao(dao: taskDaoHelper)
        if let selectedRecord = taskDao.findById(taskId: taskId) {
            XCTAssertEqual(selectedRecord.taskId, taskId)
            XCTAssertEqual(selectedRecord.title, expectedValueOfTitle)
            XCTAssertNotNil(selectedRecord.limitDate)
            XCTAssertEqual(selectedRecord.limitDate, expectedValueOfDate)
            XCTAssertEqual(selectedRecord.isDone, expectedValueOfIsDone)
        } else {
            XCTFail("The record not found.")
        }
    }
    
}
