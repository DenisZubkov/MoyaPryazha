//
//  ProductParameter.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ProductParamsJSON: Codable {
    let productID, paramID, paramTitle, paramTtip: String
    let paramValue: String
    
    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case paramID = "paramId"
        case paramTitle, paramTtip, paramValue
    }
}
