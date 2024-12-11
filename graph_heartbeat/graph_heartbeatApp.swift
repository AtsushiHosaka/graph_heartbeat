//
//  graph_heartbeatApp.swift
//  graph_heartbeat
//
//  Created by 保坂篤志 on 2023/06/19.
//

import SwiftUI

@main
struct graph_heartbeatApp: App {
    @StateObject private var viewModel = IPhoneViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(viewModel)
        }
    }
}
