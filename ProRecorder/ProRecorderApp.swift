//
//  ProRecorderApp.swift
//  ProRecorder
//
//  Created by Simon Puchner on 30.06.22.
//

import SwiftUI
import UIKit

@main
struct ProRecorderApp: App {
    let persistenceController = PersistenceController.shared
    
    let projectViewModel = ProjectViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                ProjectsView()
                    .tabItem {
                        Label("Projects", systemImage: "list.bullet.rectangle.portrait")
                    }
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                StatisticsView()
                    .tabItem {
                        Label("Statistics", systemImage: "align.vertical.bottom")
                    }
            }
            .environmentObject(projectViewModel)
        }
    }
}





