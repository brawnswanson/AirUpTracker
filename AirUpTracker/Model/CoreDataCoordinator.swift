//
//  CoreDataCoordinator.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 25.04.22.
//
import Foundation
import CoreData
import UIKit

class CoreDataCoordinator {
    
    static let sharedCoreData = CoreDataCoordinator()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AirUpModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    private init() {}
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context")
        }
    }
    
    func createEntity(entity: NSEntityDescription, keyedValues: [String:Any]) -> NSManagedObject {
        let newObject = NSManagedObject(entity: entity, insertInto: context)
        newObject.setValue(UUID(), forKey: "id")
        updateEntity(objectToUpdate: newObject, keyedValues: keyedValues)
        return newObject
    }
    
    func updateEntity(objectToUpdate: NSManagedObject, keyedValues: [String:Any]) {
        for (key, value) in keyedValues {
            objectToUpdate.setValue(value, forKey: key)
        }
        save()
    }
    
    func deleteEntity(objectToDelete: NSManagedObject) {
        context.delete(objectToDelete)
        save()
    }
}

enum InventoryError: Error {
    case saveError
    
    var localizedDescription: String {
        switch self {
        case .saveError:
            return "Error saving data. If problem persists please contact administrator"
        }
    }
}

enum CreateCategoryKeys: String {
    case id
    case name
    case minimumDesiredInventoryMagnitude
    case minimumDesiredInventoryUnits
}

enum CreateItemInfoKeys: String {
    case name
    case barCode
    case packageQuantityMagnitude
    case packageQuantityUnits
    case shelfLifeInMonths
    case location
}
