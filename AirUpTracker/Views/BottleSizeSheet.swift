//
//  BottleSizeSheer.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 28.04.22.
//

import SwiftUI

struct BottleSizeSheet: View {
    
    @Environment(\.presentationMode) var isPresented
    @State var bottleSizeInMl: Double = 0
    @AppStorage("bottleSize") var defaultBottleSizeInMl: Int = 650
    private var litersLabel: String {
        bottleSizeInMl == 1 ? "liter" : "liters"
    }
    
    var body: some View {
       
            Form {
                Section(content: {
                    HStack {
                        Slider(value: $bottleSizeInMl, in: 0...2000, step: 50, label: {}, onEditingChanged: { _ in })
                        Text("\(Int(bottleSizeInMl)) \(litersLabel)")
                    }
                }, header: { Text("Set Default Bottle Size")})
            }
    
        .onAppear(perform:  {
            bottleSizeInMl = Double(defaultBottleSizeInMl)
        })
        .navigationTitle("Default Bottle Size")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { save() }, label: { Text("Save")})
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {isPresented.wrappedValue.dismiss()}, label: { Text("Cancel")})
            }
        }
    }
    
    func save() {
        defaultBottleSizeInMl = Int(bottleSizeInMl)
        isPresented.wrappedValue.dismiss()
    }
    
}

struct BottleSizeSheet_Previews: PreviewProvider {
    static var previews: some View {
        BottleSizeSheet()
    }
}
