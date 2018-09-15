//
//  ProductPicture+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension ProductPicture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductPicture> {
        return NSFetchRequest<ProductPicture>(entityName: "ProductPicture")
    }

    @NSManaged public var id: Int32
    @NSManaged public var image: NSData?
    @NSManaged public var order: Int32
    @NSManaged public var path: String?
    @NSManaged public var product: Product?

}
