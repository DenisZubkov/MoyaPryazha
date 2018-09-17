//
//  CategoryJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation


struct CategoryJSON: Codable {
    let id, parentId, name, descriprion: String
    let picture, thumbnail, order: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parentId"
        case name, descriprion, picture, thumbnail
        case order = "ordering"
    }
}
