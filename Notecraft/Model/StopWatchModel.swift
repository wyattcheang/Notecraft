//
//  StopWatchModel.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 06/07/2024.
//

import Foundation

@Observable
class StopWatchModel {
    var time: Int = 0
    
    var hour: Int {
        time / 3600
    }
    
    var minute: Int {
        (time % 3600) / 60
    }
    
    var second: Int {
        time % 60
    }
    var formatTime: String {
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
    
    private var timer: Timer?
    
    func start() {
        reset()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.time += 1
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func reset() {
        time = 0
        timer?.invalidate()
        timer = nil
    }
}
