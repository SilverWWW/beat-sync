//
//  SyncViewModel.swift
//  beat-sync-app
//
//  Created by Will Silver on 1/21/25.
//

import Foundation

class SyncViewModel: ObservableObject {
    
    private var millisecondIntervals = [Int]()
    private var lastTapped: Int?
    
    private var closeSyncView: () -> (Void)
    private var didMeasureBPM: (Int) -> (Void)
    
    init(closeSyncView: @escaping () -> (Void), didMeasureBPM: @escaping (Int) -> (Void)) {
        self.closeSyncView = closeSyncView
        self.didMeasureBPM = didMeasureBPM
    }
    
    @MainActor
    func closeSync() {
        self.closeSyncView()
    }
    
    func screenTapped(when: UInt64) {
        let millisecondTime = Int(when / 1_000_000)
        guard let intervalStart = lastTapped else {
            lastTapped = millisecondTime
            return
        }
        millisecondIntervals.append(millisecondTime - intervalStart)
        lastTapped = millisecondTime
        
        if millisecondIntervals.count == 5 {
            let averageInterval = millisecondIntervals.reduce(0, +) / millisecondIntervals.count
            let maxInterval = millisecondIntervals.max() ?? averageInterval
            let minInterval = millisecondIntervals.min() ?? averageInterval
        
            // make sure the data is consistent, don't count it with outliers
            guard maxInterval - averageInterval < 200, averageInterval - minInterval < 200 else {
                self.resetData()
                return
            }
            let bpm = 60_000 / averageInterval
            self.didMeasureBPM(bpm)
            DispatchQueue.main.async {
                self.closeSync()
            }
        }
    }
    
    func resetData() {
        millisecondIntervals = []
        lastTapped = nil
    }
    
    
}
