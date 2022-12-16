//
//  User+CoreDataProperties.swift
//  
//
//  Created by Артем Макар on 15.12.22.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var user: String?
    @NSManaged public var isMain: Bool
    @NSManaged public var relationship: NSOrderedSet?

}

// MARK: Generated accessors for relationship
extension User {

    @objc(insertObject:inRelationshipAtIndex:)
    @NSManaged public func insertIntoRelationship(_ value: Favorite, at idx: Int)

    @objc(removeObjectFromRelationshipAtIndex:)
    @NSManaged public func removeFromRelationship(at idx: Int)

    @objc(insertRelationship:atIndexes:)
    @NSManaged public func insertIntoRelationship(_ values: [Favorite], at indexes: NSIndexSet)

    @objc(removeRelationshipAtIndexes:)
    @NSManaged public func removeFromRelationship(at indexes: NSIndexSet)

    @objc(replaceObjectInRelationshipAtIndex:withObject:)
    @NSManaged public func replaceRelationship(at idx: Int, with value: Favorite)

    @objc(replaceRelationshipAtIndexes:withRelationship:)
    @NSManaged public func replaceRelationship(at indexes: NSIndexSet, with values: [Favorite])

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Favorite)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Favorite)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSOrderedSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSOrderedSet)

}
