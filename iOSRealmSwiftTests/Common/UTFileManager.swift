//
//  UTFileManager.swift
//  iOSRealmSwiftTests
//
//  Created by YukiOkudera on 2018/08/18.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation

final class UTFileManager {

    private static let utDirectory = NSSearchPathForDirectoriesInDomains(
        .documentDirectory,
        .userDomainMask,
        true)[0].appendingPathComponent("UnitTest")

    /// UT用のRealmのPATHを取得する
    static func getUTRealmPath() -> String {

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: utDirectory) {
            do {
                try fileManager.createDirectory(atPath: utDirectory,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
            } catch {
                fatalError("UnitTestディレクトリ作成失敗\n\(error.localizedDescription)")
            }
        }

        let utTestRealmPath = utDirectory.appendingPathComponent("test.realm")
        print("[UT]RealmPATH:\(utTestRealmPath)")
        return utTestRealmPath
    }

    /// Documentsディレクトリ直下にUnitTestディレクトリが存在したら、削除する
    static func removeUTDirectory() {

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: utDirectory) {
            return
        }

        do {
            try fileManager.removeItem(atPath: utDirectory)
        } catch (let error) {
            fatalError("UnitTestディレクトリ削除失敗\n\(error.localizedDescription)")
        }
    }

}

private extension String {

    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
