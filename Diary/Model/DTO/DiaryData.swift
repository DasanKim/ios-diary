//
//  DiaryData.swift
//  Diary
//
//  Created by Dasan, kyungmin on 2023/08/28.
//

struct DiaryData: Decodable {
    let title: String
    let body: String
    let createdDate: Int
    
    private enum CodingKeys: String, CodingKey {
        case title
        case body
        case createdDate = "created_at"
    }
}
