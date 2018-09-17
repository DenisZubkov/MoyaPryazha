//
//  HitJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct HitJSON: Codable {
    let productId, ordered: String
    
    enum CodingKeys: String, CodingKey {
        case productId = "productId"
        case ordered
    }
}
