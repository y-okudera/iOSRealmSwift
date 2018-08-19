# iOSRealmSwift
RealmSwiftのサンプル

## 開発環境
|Category|Version|
|:-----:|:-----:|
|Xcode|9.4.1(9F2000)|
|Carthage|0.30.1|

## データモデル

テーブル毎にObjectクラスを継承したデータモデルクラスを実装する。

TaskEntity.swift
```
import Foundation
import RealmSwift

final class TaskEntity: Object {

    @objc dynamic var taskId = 1
    @objc dynamic var title = ""
    @objc dynamic var limitDate: Date?
    @objc dynamic var isDone = false

    override static func primaryKey() -> String? {
        return "taskId"
    }

    /*
     RealmSwift.Objectを継承したモデルクラスにInitializerを追加する場合はConvenience Initializerを実装する
     （Object.init()のoverrideはサポートされていないため）
     */
    convenience init(taskId: Int = 1, title: String, limitDate: Date?, isDone: Bool = false) {
        self.init()
        self.taskId = taskId
        self.title = title
        self.limitDate = limitDate
        self.isDone = isDone
    }
}
```

`override static func primaryKey() -> String?` で、primaryKeyを設定するプロパティの名称を指定する。

## 他のデータモデルとのリレーション

#### 1対1の場合
`@objc dynamic var otherEntity: OtherEntity?`

#### 1対多の場合
`let taskList = List<TaskEntity>()`
（List typeをletで定義しなければならない。）

## Results<Element> Typeの変換
`Results<T>`を`[T]`に変換する場合は、`Array()`で囲む。
```
let allObjects = realm.objects(TheObject.self) // Results<TheObject>
let allObjectsArray = Array(allObjects) // [TheObject]
```

## Managed ObjectをStandalone Objectにする

Standalone Objectに変換すると、以下が可能になる。
- Write Transaction外での値の変更
- スレッド間の受け渡し

```
func findById(folderId: Int) -> FolderEntity? {

    // ManagedObject
    guard let managedObject = realm.object(ofType: FolderEntity.self, forPrimaryKey: id) else {
        return nil
    }

    // ManagedObjectからStandaloneObjectに変換する
    let standaloneObject = FolderEntity(value: managedObject)
    return standaloneObject
}
```

## RealmのListクラスをCodableに準拠させる

List+ConformToCodable.swift
```
import Foundation
import RealmSwift

extension List: Decodable where Element: Decodable {
    public convenience init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let element = try container.decode(Element.self)
            self.append(element)
        }
    }
}

extension List: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try element.encode(to: container.superEncoder())
        }
    }
}
```
