//
//  TravelogueApp.swift
//  Travelogue
//
//  Created by Sayantan Chakraborty on 23/12/20.
//

import SwiftUI

@main
struct TravelogueApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
