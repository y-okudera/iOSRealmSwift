//
//  RealmMigratorTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/21.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
import RealmSwift
@testable import iOSRealmSwift

final class RealmMigratorTests: XCTestCase {

    // MARK: - setUp

    override func setUp() {
        super.setUp()
        UTFileManager.removeUTDirectory()
    }

    /// スキーマバージョン0から1へのマイグレーションをテスト
    func testSchemaVersion0To1() {

        setTestRecords(defaultSchemaVersion: 0)

        let service = RealmInitializerForTest.realmInitializeService()
        RealmMigrator.migrate(newSchemaVersion: 1, configuration: service.configuration)

        let realm = try! Realm(configuration: service.configuration!)
        XCTAssertEqual(realm.objects(TaskEntity.self).count, 3)
        XCTAssertEqual(realm.objects(FolderEntity.self).count, 1)
        XCTAssertEqual(realm.configuration.schemaVersion, 1)
    }

    /// スキーマバージョン0から2へのマイグレーションをテスト
    func testSchemaVersion0To2() {

        setTestRecords(defaultSchemaVersion: 0)

        let service = RealmInitializerForTest.realmInitializeService()
        RealmMigrator.migrate(newSchemaVersion: 2, configuration: service.configuration)

        let realm = try! Realm(configuration: service.configuration!)
        XCTAssertEqual(realm.objects(TaskEntity.self).count, 3)
        XCTAssertEqual(realm.objects(FolderEntity.self).count, 1)
        XCTAssertEqual(realm.configuration.schemaVersion, 2)
    }

    /// スキーマバージョン1から2へのマイグレーションをテスト
    func testSchemaVersion1To2() {

        setTestRecords(defaultSchemaVersion: 1)

        let service = RealmInitializerForTest.realmInitializeService()
        RealmMigrator.migrate(newSchemaVersion: 2, configuration: service.configuration)

        let realm = try! Realm(configuration: service.configuration!)
        XCTAssertEqual(realm.objects(TaskEntity.self).count, 3)
        XCTAssertEqual(realm.objects(FolderEntity.self).count, 2)
        XCTAssertEqual(realm.configuration.schemaVersion, 2)
    }

    // MARK: - Private methods
    
    /// マイグレーションテスト用のRealmファイルを生成する
    ///
    /// タスク3件、フォルダ2件（タスク有りフォルダ1, 空フォルダ1）のレコードを持つ
    ///
    /// - Parameter defaultSchemaVersion: スキーマバージョン
    private func setTestRecords(defaultSchemaVersion: UInt64 = 0) {

        if FileManager.default.fileExists(atPath: UTFileManager.getUTRealmPath()) {
            do {
                try FileManager.default.removeItem(atPath: UTFileManager.getUTRealmPath())
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        // データを事前に登録するためのRealmのPATH
        let defaultRealmForMigrationTest = UTFileManager.getUTRealmPath()
            .deletingLastPathComponent
            .appendingPathComponent("default.realm")

        let service = RealmInitializerForTest.realmInitializeService(filePath: defaultRealmForMigrationTest)
        var configuration = service.configuration!
        configuration.schemaVersion = defaultSchemaVersion
        let realm = try! Realm(configuration: configuration)

        let task1 = TaskEntity(taskId: 1, title: "タスク1", limitDate: Date(), isDone: false)
        let task2 = TaskEntity(taskId: 2, title: "タスク2", limitDate: Date(), isDone: false)
        let task3 = TaskEntity(taskId: 3, title: "タスク3", limitDate: Date(), isDone: false)
        let folder1 = FolderEntity(folderId: 1, title: "フォルダ1", lastUpdated: Date(), taskList: [task1])
        let folder2 = FolderEntity(folderId: 2, title: "フォルダ2", lastUpdated: Date(), taskList: [])

        do {
            try realm.write {
                realm.add(task1)
                realm.add(task2)
                realm.add(task3)
                realm.add(folder1)
                realm.add(folder2)
                if let theFolder = realm.object(ofType: FolderEntity.self, forPrimaryKey: 1 as AnyObject) {
                    theFolder.taskList.append(task1)
                    realm.add(theFolder, update: true)
                }
            }
        } catch {
            XCTFail(error.localizedDescription)
        }

        // データを登録したRealmファイルをテスト用のPATHに移動
        do {
            try FileManager.default.moveItem(atPath: defaultRealmForMigrationTest, toPath: UTFileManager.getUTRealmPath())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

private extension String {

    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }

    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
