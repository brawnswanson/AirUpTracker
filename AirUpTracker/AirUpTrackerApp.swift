//
//  AirUpTrackerApp.swift
//  AirUpTracker
//
//  Created by Daniel Pressner on 25.04.22.
//
//TODO: Picker or menu to add different amounts, including default amount
//TODO: Animate pod rating
//TODO: AppStorage keys
//TODO: Do something better with use counts
//TODO: Stop using app storage except for actual settings
//TODO: Use count and stars on flavor list
//TODO: Graph axis label too close to edge
//TODO: Water tracking
//TODO: Long press on water symbol opens change bottle size?

import SwiftUI

@main
struct AirUpTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            AirUpTrackerHomeView()
                .environment(\.managedObjectContext, CoreDataCoordinator.sharedCoreData.context)
                .onAppear(perform: {
                    ValueTransformer.setValueTransformer(ColorTransfomer(), forName: .transformerName)
                })
        }
    }
}
