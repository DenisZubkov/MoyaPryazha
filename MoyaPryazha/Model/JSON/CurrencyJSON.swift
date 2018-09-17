//
//  CurrencyJSON.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct CurrencyJSON: Codable {
    let id, name, code, numericCode: String
    let symbol, decimalPlace: String
}
