//
//  DiaryData.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/08/28.
//

import Foundation

struct DiaryData: Decodable {
    let title: String
    let body: String
    let createdDate: Int
    
    private enum CodingKeys: String, CodingKey {
        case title
        case body
        case createdDate = "created_at"
    }
    
    // Diary가 associatedtype가 되면!!
    func toDomain() -> Diary {
        return Diary(
            identifier: UUID(),
            title: self.title,
            body: self.body,
            createdDate: DateFormatter().dateString(
                from: Date(timeIntervalSince1970: Double(self.createdDate)),
                at: DateManager().getPreferredLocale(),
                with: DateManager.FormatTemplate.attached)
        )
    }
}
