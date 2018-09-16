//
//  Product+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var desc: NSData?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var order: Int32
    @NSManaged public var category: Category?
    @NSManaged public var hit: Hit?
    @NSManaged public var pictures: NSSet?
    @NSManaged public var prices: NSSet?
    @NSManaged public var productParameters: NSSet?

}

// MARK: Generated accessors for pictures
extension Product {

    @objc(addPicturesObject:)
    @NSManaged public func addToPictures(_ value: ProductPicture)

    @objc(removePicturesObject:)
    @NSManaged public func removeFromPictures(_ value: ProductPicture)

    @objc(addPictures:)
    @NSManaged public func addToPictures(_ values: NSSet)

    @objc(removePictures:)
    @NSManaged public func removeFromPictures(_ values: NSSet)

}

// MARK: Generated accessors for prices
extension Product {

    @objc(addPricesObject:)
    @NSManaged public func addToPrices(_ value: Price)

    @objc(removePricesObject:)
    @NSManaged public func removeFromPrices(_ value: Price)

    @objc(addPrices:)
    @NSManaged public func addToPrices(_ values: NSSet)

    @objc(removePrices:)
    @NSManaged public func removeFromPrices(_ values: NSSet)

}

// MARK: Generated accessors for productParameters
extension Product {

    @objc(addProductParametersObject:)
    @NSManaged public func addToProductParameters(_ value: ProductParameter)

    @objc(removeProductParametersObject:)
    @NSManaged public func removeFromProductParameters(_ value: ProductParameter)

    @objc(addProductParameters:)
    @NSManaged public func addToProductParameters(_ values: NSSet)

    @objc(removeProductParameters:)
    @NSManaged public func removeFromProductParameters(_ values: NSSet)

}
