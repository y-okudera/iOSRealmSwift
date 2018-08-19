//
//  RealmDaoHelperTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
import RealmSwift
@testable import iOSRealmSwift

final class RealmDaoHelperTests: XCTestCase {

    private var testDaoHelper: RealmDaoHelper<TestEntity> {
        let service = RealmInitializerForTest.realmInitializeService()
        return RealmDaoHelper<TestEntity>(service: service)
    }

    private var noPKDaoHelper: RealmDaoHelper<NoPrimaryKeyEntity> {
        let service = RealmInitializerForTest.realmInitializeService()
        return RealmDaoHelper<NoPrimaryKeyEntity>(service: service)
    }

    // MARK: - setUp
    
    override func setUp() {
        super.setUp()
        UTFileManager.removeUTDirectory()
    }

    // MARK: - Test to create a new primary key

    /// 新規主キー発行処理をテスト
    func testNewId() {

        // レコードが0件の場合、1を返すことをテスト
        XCTAssertEqual(testDaoHelper.newId(), 1)

        // レコードを1件追加
        let testEntity1 = TestEntity(id: testDaoHelper.newId()!, title: "テスト1", date: Date())
        testDaoHelper.add(d: testEntity1)

        // レコードが1件追加された後、newIdが2を返すことをテスト
        XCTAssertEqual(testDaoHelper.newId(), 2)

        let testEntity2 = TestEntity(id: testDaoHelper.newId()!, title: "テスト2", date: Date())
        testDaoHelper.add(d: testEntity2)

        XCTAssertEqual(testDaoHelper.newId(), 3)

        // id1のレコードを削除
        let _ = testDaoHelper.delete(d: testEntity1)

        // id1のレコードが削除された後、newIdが3を返すことをテスト(残存レコードのidの最大値が2のため)
        XCTAssertEqual(testDaoHelper.newId(), 3)

        // id2のレコードを削除
        let _ = testDaoHelper.delete(d: testEntity2)

        // id2のレコードが削除された後、newIdが1を返すことをテスト(残存レコード1件も無くなるため)
        XCTAssertEqual(testDaoHelper.newId(), 1)
    }

    /// 新規主キー発行処理をテスト（primaryKey未設定ケース）
    func testNewIdNoPK() {
        // newIdがnilを返却することをテスト
        XCTAssertNil(noPKDaoHelper.newId())
    }

    // MARK: - Test to add record

    /// レコード追加処理をテスト
    func testAdd() {

        // レコード数が0件であることをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 0)

        // レコードを1件追加
        let dateString = "2018-08-19 11:22:33"
        let date = dateString.toDate()
        let testEntity1 = TestEntity(id: testDaoHelper.newId()!, title: "テスト1", date: date)
        testDaoHelper.add(d: testEntity1)

        // レコード数が1件になっていることをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 1)

        // レコードを取得し、内容をテスト
        if let selectedTestEntity = testDaoHelper.findAllConvertedToArray().first {

            XCTAssertEqual(selectedTestEntity.id, 1)
            XCTAssertEqual(selectedTestEntity.title, "テスト1")

            XCTAssertNotNil(selectedTestEntity.date)
            XCTAssertEqual(selectedTestEntity.date, date)
        } else {
            XCTFail("The record not found.")
        }
    }

    // MARK: - Test to update record

    /// レコード更新処理をテスト
    func testUpdate() {

        // レコード数が0件であることをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 0)

        // レコードを1件追加
        let dateString = "2018-08-19 11:22:33"
        let date = dateString.toDate()
        let testEntity1 = TestEntity(id: testDaoHelper.newId()!, title: "テスト1", date: date)
        testDaoHelper.add(d: testEntity1)

        // レコード数が1件になっていることをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 1)

        let updatedDateString = "2018-08-20 11:22:33"
        let updatedDate = updatedDateString.toDate()
        let updatedTestEntity1 = TestEntity(id: testEntity1.id, title: "テスト1(更新版)", date: updatedDate)
        let updateResult = testDaoHelper.update(d: updatedTestEntity1)

        if !updateResult {
            XCTFail("Failed to update.")
        }

        // レコード数が1件から変わっていないことをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 1)

        // レコードを取得し、内容をテスト
        if let selectedTestEntity = testDaoHelper.findAllConvertedToArray().first {

            XCTAssertEqual(selectedTestEntity.id, 1)
            XCTAssertEqual(selectedTestEntity.title, "テスト1(更新版)")

            XCTAssertNotNil(selectedTestEntity.date)
            XCTAssertEqual(selectedTestEntity.date, updatedDate)
        } else {
            XCTFail("The record not found.")
        }
    }

    // MARK: - Test to delete records

    /// レコード全削除処理をテスト
    func testDeleteAll() {

        // レコードを2件追加
        let testEntity1 = TestEntity(id: testDaoHelper.newId()!, title: "テスト1", date: Date())
        testDaoHelper.add(d: testEntity1)
        let testEntity2 = TestEntity(id: testDaoHelper.newId()!, title: "テスト2", date: Date())
        testDaoHelper.add(d: testEntity2)

        // レコード数が2件であることをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 2)

        // レコードを全件削除
        let deleteResult = testDaoHelper.deleteAll()

        if !deleteResult {
            XCTFail("Failed to delete.")
        }

        // レコード数が0件になっていることをテスト
        XCTAssertEqual(testDaoHelper.findAll().count, 0)
    }
}

// MARK: - TestEntity class

final class TestEntity: Object {

    @objc dynamic var id = 1
    @objc dynamic var title = ""
    @objc dynamic var date: Date?

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: Int = 1, title: String, date: Date?) {
        self.init()
        self.id = id
        self.title = title
        self.date = date
    }
}

// MARK: - NoPrimaryKeyEntity class

final class NoPrimaryKeyEntity: Object {

    @objc dynamic var id = 1
    @objc dynamic var title = ""
    @objc dynamic var date: Date?
}
