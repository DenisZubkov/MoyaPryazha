//
//  PriceType+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension PriceType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PriceType> {
        return NSFetchRequest<PriceType>(entityName: "PriceType")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var prices: NSSet?

}

// MARK: Generated accessors for prices
extension PriceType {

    @objc(addPricesObject:)
    @NSManaged public func addToPrices(_ value: Price)

    @objc(removePricesObject:)
    @NSManaged public func removeFromPrices(_ value: Price)

    @objc(addPrices:)
    @NSManaged public func addToPrices(_ values: NSSet)

    @objc(removePrices:)
    @NSManaged public func removeFromPrices(_ values: NSSet)

}
