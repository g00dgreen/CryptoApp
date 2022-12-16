//
//  CoreDataModel.swift
//  testAPI
//
//  Created by Артем Макар on 15.12.22.
//

import Foundation
import CoreData
class CoreDataManager {
    
    static var coreDataManager = CoreDataManager()
    static var user = coreDataManager.mainUser()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
     
    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext

    
    func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
           }
     }

    func mainUser() -> User {
        let fetchRecuest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRecuest.predicate = NSPredicate(format: "isMain = true")
        if let users = try? viewContext.fetch(fetchRecuest) as? [User], !users.isEmpty {
            return users.first!
        } else {
            let user = User(context: viewContext)
            user.user = "Main"
            user.isMain = true
            do {
                try viewContext.save()
            } catch let error {
                print(error)
            }
            
            return user
        }

    }
    func apdateUser(id: String, isAdd: Bool) {
        let favorite = Favorite(context: viewContext)
        favorite.cryptoID = id
        
        let fetchRecuest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRecuest.predicate = NSPredicate(format: "isMain = true")
        
        if let users = try? viewContext.fetch(fetchRecuest) as? [User] {
            guard let user = users.first else {return}
            if isAdd == true {
                user.addToRelationship(favorite)
            } else if  isAdd == false{
                for i in 0..<user.relationship!.count {
//                    (((i as AnyObject).cryptoID!)!)
                    if (user.relationship![i] as AnyObject).cryptoID! == favorite.cryptoID! {
                        user.removeFromRelationship(at: i)
                        print(user.relationship?.count)
                        return
                        //print(user.relationship?.count)
                    }
                }
                //user.removeFromRelationship(favorite)
            }
            try? viewContext.save()
        }
    }
}
