//
//  NewFlavorView.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 25.04.22.
//

import SwiftUI

struct NewFlavorView: View {
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var isPresented
    
    @State var name: String = "New Flavor"
    @State var flavorCapacity = 5.0
    @State var rating = 5
    @State var color: Color = .blue
    
    var body: some View {
        Form {
            Section(content: { PodNameView(name: $name) }, header: { Text("Pod Name")})
            Section(content: { PodCapacityView(flavorCapacity: $flavorCapacity) }, header: { Text("Pod Capacity")})
            Section(content: { PodRatingView(rating: $rating) }, header: { Text("Pod Rating")})
            Section(content: { PodColorPickerView(color: $color) }, header: { Text("Pod Color")})
        }
        .navigationTitle("New Flavor")
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
    
    func save() {
        let newFlavor = Flavor(context: context)
        newFlavor.id = UUID()
        newFlavor.name = name
        newFlavor.rating = Int16(exactly: rating)!
        newFlavor.color = UIColor(color)
        newFlavor.capacity = flavorCapacity
        newFlavor.uses = 0
        CoreDataCoordinator.sharedCoreData.save()
    }
}

struct NewFlavorView_Previews: PreviewProvider {
    static var previews: some View {
        NewFlavorView()
    }
}

class ColorTransfomer: ValueTransformer {
    func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    override func transformedValue(_ value: Any?) -> Any? {
        guard let colorToTransform = value as? UIColor else { return nil }
        return try! NSKeyedArchiver.archivedData(withRootObject:colorToTransform, requiringSecureCoding: true)
       
    }
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let valueToTransform = value as? Data else { return nil }
        return try! NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: valueToTransform)
    }
}

extension NSValueTransformerName {
    static let transformerName = NSValueTransformerName("ColorTransformer")
}

struct PodNameView: View {
    
    @Binding var name: String
    
    var body: some View {
        NavigationLink(destination: { Form {
            Section {
                TextField("", text: $name)
            }
        }}, label: { Text("\(name)")})
    }
}

struct PodCapacityView: View {
    
    @Binding var flavorCapacity: Double
    @AppStorage("maxCapacity") var maxCapacity: Double = 10.0
    var literLabel: String {
        flavorCapacity == 1.0 ? "Liter" : "Liters"
    }
    
    var body: some View {
        HStack {
            Slider(value: $flavorCapacity, in: 1...maxCapacity, step: 1, label: {
                Text("\(flavorCapacity)")
            }, onEditingChanged: { _ in })
            Text("\(Int(flavorCapacity)) \(literLabel)")
        }
    }
}

struct PodRatingView: View {
    
    @Binding var rating: Int
    
    var body: some View {
        HStack {
            Button(action: { rating = 1 }, label: {Image(systemName: rating >= 0 ? "star.fill" : "star") })
            Button(action: { rating = 2 }, label: {Image(systemName: rating > 1 ? "star.fill" : "star") })
            Button(action: { rating = 3 }, label: {Image(systemName: rating > 2 ? "star.fill" : "star") })
            Button(action: { rating = 4 }, label: {Image(systemName: rating > 3 ? "star.fill" : "star") })
            Button(action: { rating = 5 }, label: {Image(systemName: rating > 4 ? "star.fill" : "star") })
        }.buttonStyle(.plain)
            .foregroundColor(.yellow)
    }
}

struct PodColorPickerView: View {
    
    @Binding var color: Color
    var colorName: String {
        let colorString = UIColor(color).accessibilityName
        return colorString.capitalized
    }
    
    var body: some View {
        HStack {
            ColorPicker("\(colorName)", selection: $color)
        }
    }
}
