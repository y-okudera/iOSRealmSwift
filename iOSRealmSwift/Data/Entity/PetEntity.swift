//
//  PetEntity.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class PetEntity: Object, Codable {

    @objc dynamic var petId = 0
    @objc dynamic var name = ""
    @objc dynamic var age = 0
    @objc dynamic var kind = ""

    override static func primaryKey() -> String? {
        return "petId"
    }

    convenience init(petID: Int, name: String, age: Int, kind: String) {
        self.init()
        self.petId = petID
        self.name = name
        self.age = age
        self.kind = kind
    }
}
