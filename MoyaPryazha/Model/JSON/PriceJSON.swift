//
//  PriceJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct PriceJSON: Codable {
    let id, productId: String
    let price: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "productId"
        case price, currency
    }
}
