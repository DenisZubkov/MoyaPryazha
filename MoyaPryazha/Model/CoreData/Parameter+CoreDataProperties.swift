//
//  Parameter+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension Parameter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Parameter> {
        return NSFetchRequest<Parameter>(entityName: "Parameter")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var tip: String?
    @NSManaged public var productParameters: NSSet?

}

// MARK: Generated accessors for productParameters
extension Parameter {

    @objc(addProductParametersObject:)
    @NSManaged public func addToProductParameters(_ value: ProductParameter)

    @objc(removeProductParametersObject:)
    @NSManaged public func removeFromProductParameters(_ value: ProductParameter)

    @objc(addProductParameters:)
    @NSManaged public func addToProductParameters(_ values: NSSet)

    @objc(removeProductParameters:)
    @NSManaged public func removeFromProductParameters(_ values: NSSet)

}
