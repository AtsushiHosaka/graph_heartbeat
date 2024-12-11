//
//  iPhoneViewModel.swift
//  graph_heartbeat
//
//  Created by 保坂篤志 on 2023/06/19.
//

import Foundation
import WatchConnectivity

//SwiftUIの記事を参照したためViewModelを作成しています。
//ViewControllerに統一したりViewModelじゃない名前に変えたりしても全然OKと思われます
final class IPhoneViewModel: NSObject, ObservableObject {
    
    static let shared = IPhoneViewModel()
    
    var session: WCSession
    
    @Published var heartbeatData: [ChartData] = []
    
    init(session: WCSession = .default) {
        
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
}

extension IPhoneViewModel: WCSessionDelegate {
    
    //sessionを開始
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    //メッセージを受け取った時呼び出されます
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        DispatchQueue.main.async {
            
            let receive = message["heartbeat"] as? Double ?? 0
            
            guard receive != 0 else { return }
            
            self.heartbeatData.append(ChartData(value: receive, id: self.heartbeatData.count))
        }
    }
}

struct ChartData: Identifiable {
    var value: Double
    var id: Int
    
    init(value: Double, id: Int) {
        self.value = value
        self.id = id
    }
}
