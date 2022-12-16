//
//  Favorite+CoreDataProperties.swift
//  
//
//  Created by Артем Макар on 15.12.22.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var cryptoID: String?
    @NSManaged public var relationship: User?

}
