//
//  ProductParameter+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension ProductParameter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductParameter> {
        return NSFetchRequest<ProductParameter>(entityName: "ProductParameter")
    }

    @NSManaged public var id: Int32
    @NSManaged public var value: String?
    @NSManaged public var parameter: Parameter?
    @NSManaged public var product: Product?

}
