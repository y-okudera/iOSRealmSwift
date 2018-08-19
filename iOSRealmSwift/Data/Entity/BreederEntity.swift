//
//  BreederEntity.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/19.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import Foundation
import RealmSwift

final class BreederEntity: Object, Codable {

    @objc dynamic var breederId = 0
    @objc dynamic var name = ""
    @objc dynamic var age = 0
    let pets = List<PetEntity>()

    override static func primaryKey() -> String? {
        return "breederId"
    }

    convenience init(breederId: Int, name: String, age: Int, pets: [PetEntity]) {
        self.init()
        self.breederId = breederId
        self.name = name
        self.age = age
        self.pets.append(objectsIn: pets)
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.breederId = try container.decode(Int.self, forKey: .breederId)
        self.name = try container.decode(String.self, forKey: .name)
        self.age = try container.decode(Int.self, forKey: .age)

        let pets = try container.decode(List<PetEntity>.self, forKey: .pets)
        self.pets.append(objectsIn: pets)
    }
}
