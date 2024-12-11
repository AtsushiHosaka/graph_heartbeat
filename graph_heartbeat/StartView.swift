//  StartView.swift

import SwiftUI

struct StartView: View {
    @State private var selectedTeam = ""
    @State private var showResultView = false
    let teams = [
        "東大",
        "Oxford",
        "お菓子食べたい",
        "宿題は当日の朝に。",
        "すいとん",
        "音じぇる",
        "菓子パ実行委員会",
        "Za Gokkyz",
        "果汁100%",
        "おそのかえる",
        "かかぱぴーこ"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("東大", selection: $selectedTeam) {
                    ForEach(teams, id: \.self) { team in
                        Text(team).tag(team)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                
                NavigationLink {
                    ContentView(teamName: selectedTeam)
                } label: {
                    Text("Start")
                }
            }
            .navigationTitle("スタート")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Results") {
                        showResultView = true
                    }
                    .sheet(isPresented: $showResultView) {
                        ResultView()
                    }
                }
            }
        }
        .onChange(of: selectedTeam) {
            print(selectedTeam)
        }
    }
}
