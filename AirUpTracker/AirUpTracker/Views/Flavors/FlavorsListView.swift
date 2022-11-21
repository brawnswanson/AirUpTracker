//
//  FlavorsListView.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 25.04.22.
//

import SwiftUI

struct FlavorsListView: View {
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var isPresented
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)], predicate: NSPredicate(value: true)) var flavors: FetchedResults<Flavor>
    @State private var newFlavorViewPresented = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    List {
                        ForEach(flavors, id:\.id) { flavor in
                            NavigationLink(destination: { EditFlavorView(flavor: flavor)}, label: {listLable(flavor: flavor) })
                            
                        }
                        .onDelete(perform: { indexSet in
                            guard let indexToDelete = indexSet.first else { return }
                            CoreDataCoordinator.sharedCoreData.deleteEntity(objectToDelete: flavors[indexToDelete])
                        })
                    }
                }
            }
            .navigationTitle("Flavors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: { Button(action: { isPresented.wrappedValue.dismiss() }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    })})
                ToolbarItem(placement:.navigationBarTrailing) {
                    Menu(content: {
                        Section {
                            Button(action: {newFlavorViewPresented.toggle()}, label: { Text("Add new flavor") })
                        }
                        Section {
                            Menu("Sort") {
                                Button(action: {flavors.sortDescriptors = [SortDescriptor(\.name, order: .forward)]}, label: { Text("Name: A to Z") })
                                Button(action: {flavors.sortDescriptors = [SortDescriptor(\.name, order: .reverse)]}, label: { Text("Name: Z to A")})
                                Button(action: {flavors.sortDescriptors = [SortDescriptor(\.rating, order: .reverse)]}, label: { Text("Rating: High to Low")})
                                Button(action: {flavors.sortDescriptors = [SortDescriptor(\.rating, order: .forward)]}, label: { Text("Rating: Low to High")})
                                Button(action: {flavors.sortDescriptors = [SortDescriptor(\.uses, order: .reverse)]}, label: { Text("Most Used")})
                                Button(action: {flavors.sortDescriptors = [SortDescriptor(\.uses, order: .forward)]}, label: { Text("Least Used")})
                            }
                        }
                    }, label: { Image(systemName: "ellipsis.circle")})
                }
            }
            .background(content: {
                NavigationLink(isActive: $newFlavorViewPresented, destination: { NewFlavorView() }, label: { EmptyView() })
            })
        }
    }
    
    @ViewBuilder
    func listLable(flavor: Flavor) -> some View {
        HStack {
            Text(flavor.name!)
                .foregroundColor(Color(flavor.color!))
            HStack {
                ForEach(1..<(Int(flavor.rating) + 1), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

struct FlavorsListView_Previews: PreviewProvider {
    static var previews: some View {
        FlavorsListView()
    }
}
