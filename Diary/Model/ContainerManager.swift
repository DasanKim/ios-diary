//
//  ContainerManager.swift
//  Diary
//
//  Created by Yena on 2023/09/06.
//

import CoreData

// 모든 타입이 들어 올 수 있게
final class ContainerManager {//<T: NSManagedObject> {
    static let shared = ContainerManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private var entity: NSEntityDescription? {
        return  NSEntityDescription.entity(forEntityName: "DiaryEntity", in: context)
    }
    
    private var count: Int {
        return fetchDiaryEntity()?.count ?? 0
    }
    
    private init() { }
    
    // core data stack - CRUD 비지니스 로직 // persistentContainer
    // core data manager 프로퍼티. viewContext
    // context.save()
    /* fetch
     do {
         let diaryEntity = try context.fetch(request)
         return diaryEntity
     } catch {
         print(error.localizedDescription)
     }
     */
    // context.delete(result)
    // context만 알면 일 시킬 수 있음
    
    private func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func insert(_ diary: Diary) {
        if let entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            managedObject.setValue(diary.identifier, forKey: "id")
            managedObject.setValue(diary.body, forKey: "content")
            managedObject.setValue(diary.title, forKey: "title")
            managedObject.setValue(diary.createdDate, forKey: "createdDate")
            managedObject.setValue(count, forKey: "number")
            
            saveContext()
        }
    }
    
    func update(_ diary: Diary) {
        guard let fetchResults = fetchDiaryEntity(),
              let result = fetchResults.filter({ $0.id == diary.identifier }).first else {
            return
        }
        
        result.title = diary.title
        result.content = diary.body
        
        saveContext()
    }
    
    func isExist(_ diary: Diary) -> Bool {
        guard let fetchResults = fetchDiaryEntity(),
              let result = fetchResults.filter({ $0.id == diary.identifier }).first else {
            return false
        }
        return true
    }
    
    func getDiary() -> [Diary]? {
        var diarys: [Diary] = []
        guard let fetchResults = fetchDiaryEntity() else { return nil }
        for result in fetchResults {
            let diary = Diary(identifier: result.id ?? UUID(), title: result.title ?? "", body: result.content ?? "", createdDate: result.createdDate ?? "")
            diarys.append(diary)
        }
        return diarys
    }
    
    // 양쪽 다 추상화해야해서 쉽지 않음...
    // 저장할 애들은 정해주는게 coreData 엔티티들은 instance
    // Associated Type’s 사용
    func fetchDiaryEntity() -> [DiaryEntity]? {
        let request = DiaryEntity.fetchRequest()
        //let request = T.fetchRequest()
        
        do {
            let diaryEntity = try context.fetch(request)
            return diaryEntity
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func delete(_ diary: Diary) {
        guard let fetchResults = fetchDiaryEntity(),
              let result = fetchResults.filter({ $0.id == diary.identifier }).first else {
            return
        }
        
        context.delete(result)
        saveContext()
    }
    
    func delete(id: UUID) {
        guard let fetchResults = fetchDiaryEntity(),
              let result = fetchResults.filter({ $0.id == id }).first else {
            return
        }
        
        context.delete(result)
        saveContext()
    }
    
    func deleteAll() {
        guard let fetchResults = fetchDiaryEntity() else {
            return
        }
        
        for result in fetchResults {
            context.delete(result)
        }
        
        saveContext()
    }
}
