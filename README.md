# iOSRealmSwift
RealmSwiftのサンプル

## 開発環境
|Category|Version|
|:-----:|:-----:|
|Xcode|10.2.1 (10E1001)|
|Carthage|0.32.0|

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

FolderEntity
```
import Foundation
import RealmSwift

final class FolderEntity: Object {

    @objc dynamic var folderId = 1
    @objc dynamic var title = ""
    @objc dynamic var lastUpdated: Date?
    let taskList = List<TaskEntity>()

    override static func primaryKey() -> String? {
        return "folderId"
    }

    /*
     RealmSwift.Objectを継承したモデルクラスにInitializerを追加する場合はConvenience Initializerを実装する
     （Object.init()のoverrideはサポートされていないため）
     */
    convenience init(folderId: Int = 1, title: String, lastUpdated: Date?, taskList: [TaskEntity] = []) {
        self.init()
        self.folderId = folderId
        self.title = title
        self.lastUpdated = lastUpdated
        self.taskList.append(objectsIn: taskList)
    }
}
```
#### PrimaryKeyの設定
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

## マイグレーション
Realmのモデル定義を変更した場合は、古い定義のRealmファイルを新しい定義のRealmファイルへマイグレーションする必要がある。
1. Realm.Configurationにマイグレーションハンドラを設定する。
2. マイグレーションハンドラ内でマイグレーション処理を実行する。
3. 新しいスキーマバージョンを設定する。
4. Realmのインスタンスを生成する。

初回のRealmインスタンス生成時に現在のRealmファイルのスキーマバージョンと今回設定したスキーマバージョンが異なる場合、マイグレーションが実行される。

```
import Realm
import RealmSwift

final class RealmMigrator {

    /// Realmのマイグレーション
    ///
    /// リリース時にマイグレーションが必要な場合は、newSchemaVersionをインクリメントする
    ///
    /// - Parameters:
    ///   - newSchemaVersion: 新しいスキーマバージョン
    ///   - configuration: Realmコンフィグレーション
    static func migrate(newSchemaVersion: UInt64, configuration: Realm.Configuration? = nil) {

        var configuration = configuration ?? Realm.Configuration()

        /// SchemaVersion1更新フラグ
        var needsMigrationToV1 = false

        configuration.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // データベース内にある全てのTaskEntityモデルを列挙
                migration.enumerateObjects(ofType: TaskEntity.className(), { oldObject, newObject in

                    // 古いオブジェクトからtitleを取得
                    let oldTitle = oldObject!["title"] as! String

                    // 新しいオブジェクトのtitleに新しい値を設定
                    newObject?["title"] = "[UPDATED]\(oldTitle)"
                })

                needsMigrationToV1 = true
            }

            if oldSchemaVersion < 2 {
                // 何もしないマイグレーション
            }
        }

        // スキーマバージョンを設定（デフォルト値は0）
        configuration.schemaVersion = newSchemaVersion

        let realmInitializer = RealmInitializer(configuration: configuration)
        let realm = realmInitializer.initializeRealm()
        print("Realm SchemaVersion: \(realm.configuration.schemaVersion)")

        // migrationブロックではListTypeのマイグレーションができないため、通常のRealmAPIを使用してマイグレーションを実行する
        if needsMigrationToV1 {
            // 全てのFolderEntityのうち、taskListが0件のレコードを削除する
            let allFolders = realm.objects(FolderEntity.self)
            do {
                try realm.write {
                    for folder in allFolders where folder.taskList.count == 0 {
                        realm.delete(folder)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
```

## スレッド間でオブジェクトを受け渡す
ThreadSafeReferenceを使用して、オブジェクトをスレッド間で受け渡す。

```
// メインスレッド

let dao = RealmDaoHelper<FolderEntity>()

// レコードを追加
dao.add(d: FolderEntity(title: "メインスレッド", lastUpdated: Date()))

// レコードを取得
guard let theFolder = dao.findById(id: 1 as AnyObject) else {
    return
}

// サブスレッドに受け渡す
let folderRef = ThreadSafeReference(to: theFolder)

DispatchQueue.global().async {
    // サブスレッド

    autoreleasepool {
        let dao = RealmDaoHelper<FolderEntity>()

        // オブジェクトへの参照を取得する
        guard let object = dao.realm.resolve(folderRef) else {
            print("対象のObjectが既に削除済み")
            return
        }

        // レコードを更新
        let updateResult = dao.update(d: object, block: {
            object.title = "サブスレッド"
        })

        if updateResult {
            print("更新成功")
        } else {
            print("更新失敗")
        }
    }        
}
```
