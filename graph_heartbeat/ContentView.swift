//
//  ContentView.swift
//  graph_heartbeat
//
//  Created by 保坂篤志 on 2023/06/19.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var viewModel: IPhoneViewModel
    @State var heartbeatData: [ChartData] = []
    var teamName: String
    
    var body: some View {
        VStack {
            Chart(heartbeatData) { data in
                LineMark(
                    x: .value("id", data.id - (heartbeatData.first?.id ?? 0)),
                    y: .value("heartRate", data.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 6))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.orange)
            }
            .chartXScale(domain: 0...10)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .padding()
            .frame(height: 300)
            
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 55))
                    .foregroundColor(.red)
                
                Spacer().frame(width: 30)
                
                Text(String(Int(viewModel.heartbeatData.last?.value ?? 0)))
                    .font(.system(size: 50, weight: .black, design: .default))
            }
        }
        .padding()
        .onChange(of: viewModel.heartbeatData.count) {
            heartbeatData = viewModel.heartbeatData.suffix(10)
        }
        .onDisappear {
            let maxVal = Int(viewModel.heartbeatData.map { $0.value }.max() ?? 0)
            let minVal = Int(viewModel.heartbeatData.map { $0.value }.min() ?? 0)
            let teamData = TeamData(
                minHeartbeat: minVal,
                maxHeartbeat: maxVal,
                teamName: teamName,
                heartbeatGraph: viewModel.heartbeatData
            )
            DataManager.shared.results.append(teamData)
//            viewModel.session.invalidate()
            viewModel.heartbeatData.removeAll()
        }
    }
}

