//
//  DiaryEntity+CoreDataProperties.swift
//  Diary
//
//  Created by Yena on 2023/09/06.
//
//

import Foundation
import CoreData

extension DiaryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEntity> {
        return NSFetchRequest<DiaryEntity>(entityName: "DiaryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var createdDate: String?

}

extension DiaryEntity: Identifiable { }
