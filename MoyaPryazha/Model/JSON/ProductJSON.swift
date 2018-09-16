//
//  Catalog.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 09/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ProductJSON: Codable {
    let id: String
    let name: String
    let price: String?
    let thumbnail: String
    let picture: String
    let description: String
    let ordered: String
    let categoryId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case thumbnail
        case picture
        case description
        case ordered
        case categoryId
    }
}
