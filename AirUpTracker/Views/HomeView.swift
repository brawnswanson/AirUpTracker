//
//  ContentView.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 25.04.22.
//

import SwiftUI

struct AirUpTrackerHomeView: View {
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    @FetchRequest(sortDescriptors: []) var flavors: FetchedResults<Flavor>
    
    @AppStorage("startDate") var startDate: Double = Date().timeIntervalSince1970
    @AppStorage("currentFlavorName") var name: String = ""
    @AppStorage("colorRed") var red: Double = 0
    @AppStorage("colorGreen") var green: Double = 0
    @AppStorage("colorBlue") var blue: Double = 0
    @AppStorage("alpha") var alpha: Double = 0
    @AppStorage("currentCapsuleUsage") var usage: Double = 0.0
    @AppStorage("maxUsage") var maxUsage: Double = 6.0
    @AppStorage("usageScaleMax") var usageScaleMax: Int = 10
    @AppStorage("usageScaleMin") var usageScaleMin: Int = 0
    @AppStorage("bottleSize") var bottleSize: Int = 650
    
    @AppStorage("currentFlavorID") var flavorID: String = ""
    @State private var currentFlavor: Flavor?
    
    @State private var podCapacityAdjustment: Double = 0
    
    private var adjustedPodCapacity: Double {
        maxUsage + maxUsage * podCapacityAdjustment / 100.0
    }
    
    private var podCapString: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter.string(from: adjustedPodCapacity as NSNumber)!
    }
    
    private var startDateString: String {
        Date(timeIntervalSince1970: startDate).formatted(date: .abbreviated, time: .omitted)
    }
    
    private var barSize: CGFloat {
        usage >= Double(usageScaleMax) ? CGFloat(1.0) : CGFloat(usage / Double(usageScaleMax))
    }
    
    @State var editFlavorPresented = false
    @State var defaulBottleSizeSheetPresented = false
    
    var body: some View {
        GeometryReader { screenSize in
            NavigationView {
                VStack {
                   
                        podInfoText
                        GeometryReader { containerDimensions in
                            GeometryReader { litersLabelDim in
                                textWhatSize(text: "Liters", size: litersLabelDim.size)
                                    .fixedSize()
                                    .rotationEffect(Angle(degrees: 270.0), anchor: .center)
                                .position(x: -10.0, y: containerDimensions.size.height * 0.5)
                            }
                            Text("\(usageScaleMax)")
                                .position(x: 15.0, y: 0.0)
                            Text("\(usageScaleMax / 2)")
                                .position(x: 15.0, y: containerDimensions.size.height * 0.5)
                            Text("0")
                                .position(x: 15.0, y: containerDimensions.size.height)
                            
                            chartGrid(size: containerDimensions.size)
                            HStack {
                                Spacer()
                                fillBar(size: containerDimensions.size)
                                    .scaleEffect(x: 1.0, y: barSize, anchor: .bottom)
                                    .animation(.easeIn(duration: 0.3), value: barSize)
                                Spacer()
                            }
                            maxFillLine(size: containerDimensions.size)
                                .stroke(colorScheme == .dark ? .white : .black, lineWidth: 1.0)
                            Text("Pod cap. \(podCapString) l")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .multilineTextAlignment(.center)
                                .fixedSize()
                                .position(CGPoint(x: containerDimensions.size.width / 2.0, y: containerDimensions.size.height * (1.0 - adjustedPodCapacity / Double(usageScaleMax)) - 20.0))
                            Text("\(formatDouble(number: usage)) l").position(x: containerDimensions.size.width / 2.0, y: containerDimensions.size.height - 10.0)
                        }
                        .frame(height: 0.5 * screenSize.size.height)
                        .scaleEffect(x: 1.0, y: 0.9, anchor: .center)
                        .padding()
//                    .frame(minHeight: 300.0)
                    
                    VStack {
                        Text("Pod capacity adjustment")
                        HStack {
                                Slider(value: $podCapacityAdjustment, in: 0...100, step: 1, label: {
                                    Text("\(podCapacityAdjustment)%")
                                }, onEditingChanged: { _ in })
                                Text("\(Int(podCapacityAdjustment))%")
                        }.padding(.horizontal)
                    }
                    
                    HStack {
                        Button(action: {
                            usage = usage + Double(bottleSize) / 1000.0
                        }, label: { Image(systemName: "plus").font(.title2)})
                        .padding(.horizontal)
                        VStack(spacing: 5.0) {
                            Image(systemName: "drop.fill")
                            Text("\(bottleSize) ml")
                        }.foregroundColor(.blue)
                        Button(action: {
                            guard usage - Double(bottleSize) / 1000.0 >= 0.0 else { usage = 0.0
                                return
                            }
                            usage -= Double(bottleSize) / 1000.0
                        }, label: { Image(systemName: "minus").font(.title2)})
                        .padding(.horizontal)
                    }
                    .padding()
                }
                .navigationTitle("Aroma Pod Usage")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu(content: {
                            Section {
                                Menu(content: {
                                    ForEach(flavors, id:\.id) { flavor in
                                        Button(action: { startNewCapsule(flavor: flavor)}, label: { Text("\(flavor.name!) \(flavor.uses)")}).tint(Color(flavor.color!))
                                    }
                                }, label: { Text("Start New Capsule")})
                            }
                            Button(action: { editFlavorPresented.toggle() }, label: { Text("Edit Flavors")})
                            Button(action: { defaulBottleSizeSheetPresented.toggle() }, label: { Text("Set Bottle Volume")})
                        }, label: { Image(systemName: "ellipsis.circle")})
                    }
                }
                .sheet(isPresented: $editFlavorPresented, content: { FlavorsListView() })
                .sheet(isPresented: $defaulBottleSizeSheetPresented, content: { NavigationView {
                    BottleSizeSheet()
                } })
            }
        }
    }
    
    func formatDouble(number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: number as NSNumber)!
    }
    func chartGrid(size: CGSize) -> some View {
        //Chart grid fills 90% of view geometry
        //Axis labels on left of grid so in the 5% margin on the left side
        let leftEdge = size.width * 0.1 + 10.0
        let rightEdge = size.width * 0.9
        let topEdge = CGFloat(0.0)
        let bottomEdge = size.height
        let points = [(leftEdge, topEdge), (leftEdge, bottomEdge), (rightEdge, bottomEdge)]
        return createPath(points: pointsArray(from: points)).stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1.0)
    }
    
    func maxFillLine(size: CGSize) -> Path {
        var path = Path()
        let widthOfLine = (size.width * 0.9) - (size.width * 0.1 + 10.0)
        let numberOfSegments = 10.0
        let segmentLength = widthOfLine / numberOfSegments
        let y = size.height * (1.0 - adjustedPodCapacity / Double(usageScaleMax))
        var x = size.width * 0.1 + 10.0
        path.move(to: CGPoint(x: x, y: y))
        for _ in 1...Int(numberOfSegments) {
            path.addLine(to: CGPoint(x: x + segmentLength / 2.0, y: y))
            path.move(to: CGPoint(x: x + segmentLength, y: y))
            x = x + segmentLength
        }
        return path
    }
    
    func fillBar(size: CGSize) -> some View {
        let rectangle = Rectangle()
            .fill(Color(red: red, green: green, blue: blue))
            .frame(width: size.width * 0.25, height: size.height, alignment: .center)
        return rectangle
    }
    
    func textWhatSize(text: String, size: CGSize) -> some View {
        return Text("\(text)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AirUpTrackerHomeView()
    }
}

extension AirUpTrackerHomeView {
    
    var podInfoText: some View {
        VStack {
            Text("\(name)")
                .font(.title)
                .foregroundColor(Color(red: red, green: green, blue: blue))
            Text("started on \(startDateString)")
        }
    }
    
    func startNewCapsule(flavor: Flavor) {
        startDate = Date().timeIntervalSince1970
        name = flavor.name!
        maxUsage = flavor.capacity
        usage = 0.0
        usageScaleMax = 2 * Int(flavor.capacity)
        if let flavorColor = flavor.color {
            var floatRed: CGFloat = 0
            var floatGreen: CGFloat = 0
            var floatBlue: CGFloat = 0
            var floatAlpha: CGFloat = 0
            flavorColor.getRed(&floatRed, green: &floatGreen, blue: &floatBlue, alpha: &floatAlpha)
            red = Double(floatRed)
            blue = Double(floatBlue)
            green = Double(floatGreen)
            alpha = Double(floatAlpha)
        }
        var currentUses = flavor.uses
        currentUses += 1
        flavor.uses = currentUses
        CoreDataCoordinator.sharedCoreData.save()
    }
    
    func createPath(points: [CGPoint]) -> Path {
        var path = Path()
        path.addLines(points)
        return path
    }
    
    func pointsArray(from points: [(x: CGFloat, y: CGFloat)]) -> [CGPoint] {
        var pointsArray = [CGPoint]()
        for point in points {
            pointsArray.append(CGPoint(x: point.x, y: point.y))
        }
        return pointsArray
    }
}
