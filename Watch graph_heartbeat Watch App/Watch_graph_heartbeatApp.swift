//
//  Watch_graph_heartbeatApp.swift
//  Watch graph_heartbeat Watch App
//
//  Created by 保坂篤志 on 2023/06/19.
//

import SwiftUI

@main
struct Watch_graph_heartbeat_Watch_AppApp: App {
    
    @StateObject private var heartbeatManager = HeartbeatManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(heartbeatManager)
        }
    }
}
