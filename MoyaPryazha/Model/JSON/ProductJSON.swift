//
//  Catalog.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 09/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ProductJSON: Codable {
    let id, name, price, thumbnail: String
    let picture, description, categoryId: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, thumbnail, picture, description
        case categoryId = "categoryId"
    }
}
