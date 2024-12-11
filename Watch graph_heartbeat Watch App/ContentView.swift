//
//  ContentView.swift
//  Watch graph_heartbeat Watch App
//
//  Created by 保坂篤志 on 2023/06/19.
//

import SwiftUI

struct ContentView: View {
    
    //@Stateをつけると、その変数を変更した時、それを用いて表示されているテキストなどが更新されます。
    @State var isCollecting = false
    @State var buttonColor = Color.green
    
    var viewModel = WatchViewModel()
    
    @EnvironmentObject var heartbeatManager: HeartbeatManager
    
    var body: some View {
        
        VStack {
            if isCollecting {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    
                    Spacer().frame(width: 20)
                    
                    Text(String(Int(floor(heartbeatManager.heartRate))))
                        .font(.system(size: 45, weight: .black, design: .default))
                }
            }
            
            Spacer().frame(height: 30)
            
            Button(action: {
                buttonPressed()
            }) {
                if isCollecting {
                    Image(systemName: "pause.fill")
                }else {
                    
                    Image(systemName: "arrowtriangle.right.fill")
                }
            }
            .frame(width: 150, height: 50)
            .background(buttonColor)
            .foregroundColor(.white)
            .cornerRadius(25)
        }
        .onAppear {
            heartbeatManager.requestAuthorization()
        }
    }
    
    private func buttonPressed() {
        
        isCollecting = !isCollecting
        
        if isCollecting {
            
            buttonColor = .red
            
            heartbeatManager.startWorkout()
        }else {
            
            buttonColor = .green
            
            heartbeatManager.endWorkout()
            sendMessage()
            
            heartbeatManager.resetWorkout()
        }
    }
    
    func sendMessage() {
        let messages: [String: Any] = ["average": heartbeatManager.averageHeartRate]

        // 空のメッセージを送信し、空の replyHandler を渡す
        viewModel.session.sendMessage([:], replyHandler: { _ in }, errorHandler: nil)

        // 実際のメッセージを送信し、エラーハンドラを渡す
        viewModel.session.sendMessage(messages, replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
