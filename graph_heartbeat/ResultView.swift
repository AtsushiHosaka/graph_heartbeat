//
//  ResultView.swift
//  graph_heartbeat
//
//  Created by 保坂篤志 on 2024/12/11.
//

import SwiftUI
import Charts

struct ResultView: View {
    @State private var sortedResults: [TeamData] = []
    
    var body: some View {
        List(sortedResults) { data in
            VStack(alignment: .leading) {
                Text(data.teamName).font(.headline)
                Text("Max: \(data.maxHeartbeat), Min: \(data.minHeartbeat)")
                Chart(data.heartbeatGraph) { d in
                    LineMark(
                        x: .value("id", d.id),
                        y: .value("heartRate", d.value)
                    )
                }
                .frame(height: 150)
            }
        }
        .onAppear {
            sortedResults = DataManager.shared.results.sorted {
                ($0.maxHeartbeat - $0.minHeartbeat) > ($1.maxHeartbeat - $1.minHeartbeat)
            }
            print("sortedResults: \(sortedResults.map{$0.teamName})")
        }
        .navigationTitle("結果")
    }
}
#Preview {
    ResultView()
}
