//
//  BreederDecodableTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
@testable import iOSRealmSwift

final class BreederDecodableTests: XCTestCase {

    private var breederDaoHelper: RealmDaoHelper<BreederEntity> {
        let service = RealmInitializerForTest.realmInitializeService()
        return RealmDaoHelper<BreederEntity>(service: service)
    }

    // MARK: - setUp

    override func setUp() {
        super.setUp()
        UTFileManager.removeUTDirectory()
    }

    // MARK: - Test to json decode

    /// ブリーダーが1件の場合のJSONデコード結果をRealmに保存するテスト
    func testBreederDecodable() {
        let json = """
        {
            "breeder_id": 0,
            "name": "Mike",
            "age": 19,
            "pets": [
                {
                 "pet_id": 0,
                 "name": "pee",
                 "age": 3,
                 "kind": "Pug"
                },
                {
                 "pet_id": 1,
                 "name": "momo",
                 "age": 4,
                 "kind": "American Shorthair"
                }
             ]
        }
        """.data(using: .utf8)!

        do {
            let jsonDecoder = JSONDecoder()

            // snakeCaseからCamelCaseに変換
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

            let theBreeder = try jsonDecoder.decode(BreederEntity.self, from: json)
            self.verify(target: theBreeder)

            // JSONデコード結果をRealmに保存
            breederDaoHelper.add(d: theBreeder)

            // Realmからレコードを取得し、検証する
            let allBreeders = breederDaoHelper.findAll()
            XCTAssertEqual(allBreeders.count, 1)

            if let firstBreeder = allBreeders.first {
                self.verify(target: firstBreeder)
            } else {
                XCTFail("Saved data are not found.")
            }

        } catch {
            XCTFail("catch error:\(error)")
        }
    }

    /// ブリーダーが複数件の場合のJSONデコード結果をRealmに保存するテスト
    func testBreedersDecodable() {
        let json = """
        [
            {
                "breeder_id": 0,
                "name": "Mike",
                "age": 19,
                "pets": [
                    {
                        "pet_id": 0,
                        "name": "pee",
                        "age": 3,
                        "kind": "Pug"
                    },
                    {
                        "pet_id": 1,
                        "name": "momo",
                        "age": 4,
                        "kind": "American Shorthair"
                    }
                ]
            },
            {
                "breeder_id": 1,
                "name": "Lisa",
                "age": 21,
                "pets": [
                    {
                        "pet_id": 2,
                        "name": "leo",
                        "age": 2,
                        "kind": "Tosa"
                    }
                ]
            }
        ]
        """.data(using: .utf8)!

        do {
            let jsonDecoder = JSONDecoder()

            // snakeCaseからCamelCaseに変換
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

            let breeders = try jsonDecoder.decode([BreederEntity].self, from: json)
            self.verify(targets: breeders)

            // JSONデコード結果をRealmに保存
            breeders.forEach {
                breederDaoHelper.add(d: $0)
            }

            // Realmから全てのレコードを取得し、検証する
            let allBreeders = breederDaoHelper.findAll()
            XCTAssertEqual(allBreeders.count, 2)
            self.verify(targets: Array(allBreeders))

        } catch {
            XCTFail("catch error:\(error)")
        }
    }

    // MARK: - Private methods

    /// ブリーダーが1件の場合のJSONデコード結果を検証する
    private func verify(target: BreederEntity) {
        XCTAssertEqual(target.breederId, 0)
        XCTAssertEqual(target.name, "Mike")
        XCTAssertEqual(target.age, 19)

        XCTAssertEqual(target.pets[0].petId, 0)
        XCTAssertEqual(target.pets[0].name, "pee")
        XCTAssertEqual(target.pets[0].age, 3)
        XCTAssertEqual(target.pets[0].kind, "Pug")

        XCTAssertEqual(target.pets[1].petId, 1)
        XCTAssertEqual(target.pets[1].name, "momo")
        XCTAssertEqual(target.pets[1].age, 4)
        XCTAssertEqual(target.pets[1].kind, "American Shorthair")
    }

    /// ブリーダーが複数件の場合のJSONデコード結果を検証する
    private func verify(targets: [BreederEntity]) {
        XCTAssertEqual(targets[0].breederId, 0)
        XCTAssertEqual(targets[0].name, "Mike")
        XCTAssertEqual(targets[0].age, 19)

        XCTAssertEqual(targets[0].pets[0].petId, 0)
        XCTAssertEqual(targets[0].pets[0].name, "pee")
        XCTAssertEqual(targets[0].pets[0].age, 3)
        XCTAssertEqual(targets[0].pets[0].kind, "Pug")

        XCTAssertEqual(targets[0].pets[1].petId, 1)
        XCTAssertEqual(targets[0].pets[1].name, "momo")
        XCTAssertEqual(targets[0].pets[1].age, 4)
        XCTAssertEqual(targets[0].pets[1].kind, "American Shorthair")

        XCTAssertEqual(targets[1].breederId, 1)
        XCTAssertEqual(targets[1].name, "Lisa")
        XCTAssertEqual(targets[1].age, 21)

        XCTAssertEqual(targets[1].pets[0].petId, 2)
        XCTAssertEqual(targets[1].pets[0].name, "leo")
        XCTAssertEqual(targets[1].pets[0].age, 2)
        XCTAssertEqual(targets[1].pets[0].kind, "Tosa")
    }
}
