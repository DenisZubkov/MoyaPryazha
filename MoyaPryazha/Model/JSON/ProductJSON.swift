//
//  ProductJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 09/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ProductJSON: Codable {
    let id: String
    let slug: String
    let name: String
    let thumbnail: String?
    let description: String
    let ordered: String
    let categoryId: String
    let noShow: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case thumbnail
        case description
        case ordered
        case categoryId
        case noShow = "published"
    }
    
}
