//
//  Price+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension Price {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Price> {
        return NSFetchRequest<Price>(entityName: "Price")
    }

    @NSManaged public var id: Int32
    @NSManaged public var price: Float
    @NSManaged public var currency: Currency?
    @NSManaged public var priceType: PriceType?
    @NSManaged public var product: Product?

}
