//
//  DataManager.swift
//  graph_heartbeat
//
//  Created by 保坂篤志 on 2024/12/11.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    var results: [TeamData] = []
}

class TeamData: Identifiable {
    var id = UUID()
    var minHeartbeat: Int
    var maxHeartbeat: Int
    var teamName: String
    var heartbeatGraph: [ChartData]
    
    init(minHeartbeat: Int, maxHeartbeat: Int, teamName: String, heartbeatGraph: [ChartData]) {
        self.minHeartbeat = minHeartbeat
        self.maxHeartbeat = maxHeartbeat
        self.teamName = teamName
        self.heartbeatGraph = heartbeatGraph
    }
}
