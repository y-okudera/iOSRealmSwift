//
//  BreederEncodableTests.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import XCTest
@testable import iOSRealmSwift

final class BreederEncodableTests: XCTestCase {

    // MARK: - Test to json encode

    /// ブリーダーが1件の場合のJSONエンコードをテストする
    func testBreederEncodable() {
        let pets = [
            PetEntity(petID: 0, name: "pee", age: 3, kind: "Pug"),
            PetEntity(petID: 1, name: "momo", age: 4, kind: "American Shorthair"),
            PetEntity(petID: 2, name: "leo", age: 2, kind: "Tosa")
        ]

        let breeder = BreederEntity(breederId: 0, name: "Mike", age: 19, pets: pets)

        do {
            let encoder = JSONEncoder()
            // 読みやすい形式に変換、キー順でソート
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            // CamelCaseからsnakeCaseに変換
            encoder.keyEncodingStrategy = .convertToSnakeCase

            let jsonData = try encoder.encode(breeder)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                verifyBreeder(jsonString: jsonString)
            }

        } catch {
            XCTFail("catch error:\(error)")
        }
    }

    /// ブリーダーが複数件の場合のJSONエンコードをテストする
    func testBreedersEncodable() {
        let pets1 = [
            PetEntity(petID: 0, name: "pee", age: 3, kind: "Pug"),
            PetEntity(petID: 1, name: "momo", age: 4, kind: "American Shorthair"),
            PetEntity(petID: 2, name: "leo", age: 2, kind: "Tosa")
        ]

        let pets2 = [
            PetEntity(petID: 3, name: "sora", age: 1, kind: "Persian")
        ]

        let breeder1 = BreederEntity(breederId: 0, name: "Mike", age: 19, pets: pets1)
        let breeder2 = BreederEntity(breederId: 1, name: "Lisa", age: 21, pets: pets2)

        do {
            let encoder = JSONEncoder()
            // 読みやすい形式に変換、キー順でソート
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            // CamelCaseからsnakeCaseに変換
            encoder.keyEncodingStrategy = .convertToSnakeCase

            let jsonData = try encoder.encode([breeder1, breeder2])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                verifyBreeders(jsonString: jsonString)
            }

        } catch {
            XCTFail("catch error:\(error)")
        }
    }

    // MARK: - Private methods

    /// ブリーダーが1件の場合のJSONエンコード結果を検証する
    private func verifyBreeder(jsonString: String) {

        let expectedValue = """
        {
          "age" : 19,
          "breeder_id" : 0,
          "name" : "Mike",
          "pets" : [
            {
              "age" : 3,
              "kind" : "Pug",
              "name" : "pee",
              "pet_id" : 0
            },
            {
              "age" : 4,
              "kind" : "American Shorthair",
              "name" : "momo",
              "pet_id" : 1
            },
            {
              "age" : 2,
              "kind" : "Tosa",
              "name" : "leo",
              "pet_id" : 2
            }
          ]
        }
        """

        XCTAssertEqual(jsonString, expectedValue)
    }

    /// ブリーダーが複数件の場合のJSONエンコード結果を検証する
    private func verifyBreeders(jsonString: String) {

        let expectedValue = """
        [
          {
            "age" : 19,
            "breeder_id" : 0,
            "name" : "Mike",
            "pets" : [
              {
                "age" : 3,
                "kind" : "Pug",
                "name" : "pee",
                "pet_id" : 0
              },
              {
                "age" : 4,
                "kind" : "American Shorthair",
                "name" : "momo",
                "pet_id" : 1
              },
              {
                "age" : 2,
                "kind" : "Tosa",
                "name" : "leo",
                "pet_id" : 2
              }
            ]
          },
          {
            "age" : 21,
            "breeder_id" : 1,
            "name" : "Lisa",
            "pets" : [
              {
                "age" : 1,
                "kind" : "Persian",
                "name" : "sora",
                "pet_id" : 3
              }
            ]
          }
        ]
        """

        XCTAssertEqual(jsonString, expectedValue)
    }
}
