//
//  TimerManager.swift
//  ProRecorder
//
//  Created by Simon Puchner on 30.06.22.
//

import SwiftUI

class TimerManager: ObservableObject {
    @Published var seconds = 0
    var timer: Timer?
    
    func timerStart() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.seconds += 1
        }
    }
    
    func timerStop() {
        timer?.invalidate()
        timer = nil
        self.seconds = 0
    }
    
}
