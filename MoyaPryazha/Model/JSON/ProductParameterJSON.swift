//
//  ProductParameterJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ProductParameterJSON: Codable {
    let id, productId, parameterId : String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "productId"
        case parameterId = "parameterId"
        case value
    }
}
