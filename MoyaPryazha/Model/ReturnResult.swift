//
//  ReturnResult.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ReturnResult {
    
    var count: Int = 0
    var error: String = "Ok"
    
    init(count: Int, error: String) {
        self.count = count
        self.error = error
    }
    
}
