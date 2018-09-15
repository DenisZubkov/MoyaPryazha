//
//  Hit+CoreDataProperties.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//
//

import Foundation
import CoreData


extension Hit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hit> {
        return NSFetchRequest<Hit>(entityName: "Hit")
    }

    @NSManaged public var order: Int32
    @NSManaged public var product: Product?

}
