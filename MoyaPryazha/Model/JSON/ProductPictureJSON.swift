//
//  ProductPictureJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation


struct ProductPictureJSON: Codable {
    let id, productId, path, ordered: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "productId"
        case path, ordered
    }
}
