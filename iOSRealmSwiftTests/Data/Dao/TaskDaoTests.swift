//
//  TaskDaoTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
@testable import iOSRealmSwift

final class TaskDaoTests: XCTestCase {

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

    /// taskテーブルにレコードを追加するテスト
    func testAdd() {

        // レコード数が0件であることをテスト
        XCTAssertEqual(taskDaoHelper.findAll().count, 0)

        // レコードを1件追加
        let date = "2018-08-19 11:22:33".toDate()
        addTask(date: date)

        // レコード数が1件になっていることをテスト
        XCTAssertEqual(taskDaoHelper.findAll().count, 1)
        // レコードを取得し、検証する
        verifyTaskRecord(taskId: 1, expectedValueOfTitle: "テストタスクA", expectedValueOfDate: date, expectedValueOfIsDone: false)
    }

    // MARK: - Test to update record

    /// taskテーブルのレコードを更新するテスト
    func testUpdate() {

        // taskテーブルにレコードを追加する
        testAdd()

        let taskDao = TaskDao(dao: taskDaoHelper)
        // レコードを取得し、更新する
        if let selectedRecord = taskDao.findById(taskId: 1) {

            let limitDate = "2018-08-20 11:22:33".toDate()
            selectedRecord.title = "テストタスクB"
            selectedRecord.limitDate = limitDate
            selectedRecord.isDone = true
            taskDao.update(entity: selectedRecord)

            // 更新後のレコードを取得し、検証する
            verifyTaskRecord(taskId: 1, expectedValueOfTitle: "テストタスクB", expectedValueOfDate: limitDate, expectedValueOfIsDone: true)
        } else {
            XCTFail("The record not found.")
        }
    }

    // MARK: - Test to delete record

    /// folderテーブルのレコードを削除するテスト
    func testDelete() {

        let taskDao = TaskDao(dao: taskDaoHelper)

        // レコードを追加
        addTask(title: "テストタスクA", date: "2018-08-19 11:22:33".toDate())
        addTask(title: "テストタスクB", date: "2018-08-20 22:22:33".toDate())
        addTask(title: "テストタスクC", date: "2018-08-21 03:22:33".toDate())

        // レコード数が3件であることをテスト
        XCTAssertEqual(taskDaoHelper.findAll().count, 3)

        // id1のレコードを削除する
        taskDao.delete(taskId: 1)
        // 削除したレコードが存在しないことをテスト
        XCTAssertNil(taskDao.findById(taskId: 1))
        // レコード数が2件になっていることをテスト
        XCTAssertEqual(taskDaoHelper.findAll().count, 2)
    }

    // MARK: - Private methods

    /// レコードを追加する
    private func addTask(title: String = "テストタスクA", date: Date?) {

        let taskDao = TaskDao(dao: taskDaoHelper)
        let newTask = TaskEntity(title: title, limitDate: date)
        taskDao.add(entity: newTask)
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
