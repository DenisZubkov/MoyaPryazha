//
//  Category+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 16/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var desc: NSData?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var parentId: Int32
    @NSManaged public var picture: NSData?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var picturePath: String?
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var products: NSSet?

}

// MARK: Generated accessors for products
extension Category {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: Product)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: Product)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}
