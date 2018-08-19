//
//  MultiThreadAccessTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
import RealmSwift
@testable import iOSRealmSwift

final class MultiThreadAccessTests: XCTestCase {

    // MARK: - setUp

    override func setUp() {
        super.setUp()
        UTFileManager.removeUTDirectory()
    }

    /// スレッド間でオブジェクトを受け渡すテスト
    func testMultiThreadAccess() {

        // メインスレッド

        let service = RealmInitializerForTest.realmInitializeService()
        let dao = RealmDaoHelper<FolderEntity>(service: service)

        // レコードを追加
        dao.add(d: FolderEntity(title: "テストフォルダ1", lastUpdated: Date()))
        
        // レコードを取得
        guard let theFolder = dao.findById(id: 1 as AnyObject) else {
            XCTFail("The record not found.")
            return
        }

        // サブスレッドに受け渡す
        let folderRef = ThreadSafeReference(to: theFolder)

        DispatchQueue.global().async {
            // サブスレッド

            autoreleasepool {
                let service = RealmInitializerForTest.realmInitializeService()
                let dao = RealmDaoHelper<FolderEntity>(service: service)

                // オブジェクトへの参照を取得する
                guard let object = dao.realm.resolve(folderRef) else {
                    XCTFail("The object has already been deleted.")
                    return
                }

                // Update
                let updateResult = dao.update(d: object, block: {
                    object.title = "サブスレッドテスト"
                })

                XCTAssertTrue(updateResult)

                // レコードを取得
                guard let updatedFolder = dao.findById(id: 1 as AnyObject) else {
                    return
                }
                XCTAssertEqual(updatedFolder.title, "サブスレッドテスト")
            }
        }
    }
}
