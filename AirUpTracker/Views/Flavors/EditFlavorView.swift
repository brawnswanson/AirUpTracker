//
//  EditFlavorView.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 26.04.22.
//

import SwiftUI

struct EditFlavorView: View {
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var isPresented
    
    @State private var flavorToEdit: Flavor
    @State private var name: String
    @State private var flavorCapacity: Double
    @State private var rating: Int
    @State private var color: Color
    
    var body: some View {
        Form {
            Section(content: { PodNameView(name: $name) }, header: { Text("Pod Name")})
            Section(content: { PodCapacityView(flavorCapacity: $flavorCapacity) }, header: { Text("Pod Capacity")})
            Section(content: { PodRatingView(rating: $rating) }, header: { Text("Pod Rating")})
            Section(content: { PodColorPickerView(color: $color) }, header: { Text("Pod Color")})
        }
        .navigationTitle("Edit Flavor")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    save()
                    isPresented.wrappedValue.dismiss()
                }, label: { Text("Save")})
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {isPresented.wrappedValue.dismiss()}, label: { Text("Cancel")})
            }
        }
    }
    
    init(flavor: Flavor) {
        _flavorToEdit = State(initialValue: flavor)
        _name = State(initialValue: flavor.name!)
        _color = State(initialValue: Color(flavor.color!))
        _rating = State(initialValue: Int(flavor.rating))
        _flavorCapacity = State(initialValue: flavor.capacity)
    }
    
    func save() {
        flavorToEdit.name = name
        flavorToEdit.rating = Int16(exactly: rating)!
        flavorToEdit.color = UIColor(color)
        flavorToEdit.capacity = flavorCapacity
        CoreDataCoordinator.sharedCoreData.save()
    }
}

struct EditFlavorView_Previews: PreviewProvider {
    static var previews: some View {
        EditFlavorView(flavor: Flavor())
    }
}
