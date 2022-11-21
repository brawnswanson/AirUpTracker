//
//  Flavor+CoreDataProperties.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 26.04.22.
//
//

import Foundation
import CoreData
import SwiftUI

extension Flavor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Flavor> {
        return NSFetchRequest<Flavor>(entityName: "Flavor")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var rating: Int16
    @NSManaged public var capacity: Double
    @NSManaged public var uses: Int64
}

extension Flavor : Identifiable {

}
