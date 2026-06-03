//
//  Model.swift
//  WWSpectrumViewUI
//
//  Created by William.Weng on 2026/6/3.
//

import SwiftUI

public extension WWSpectrumViewUI {
    
    final class ViewModel: ObservableObject {
        @Published public var rawBands: [BandRaw] = []
        
        public init() {}
    }
}

public extension WWSpectrumViewUI {
    
    /// 這個結構不直接代表畫面上的 bar 高度，而是保留某個頻帶範圍內的原始 FFT bin 值，讓使用者可以自行決定如何進一步處理，例如計算平均值、RMS、峰值或轉換成 dB
    struct BandRaw {
        
        public let index: Int
        public let lowerFrequency: Float
        public let upperFrequency: Float
        public let values: [Float]
        
        /// 建立一筆原始頻帶資料
        ///
        /// - Parameters:
        ///   - index: 頻帶索引
        ///   - lowerFrequency: 頻帶最低頻率
        ///   - upperFrequency: 頻帶最高頻率
        ///   - values: 頻帶內的原始頻域值
        public init(index: Int, lowerFrequency: Float, upperFrequency: Float, values: [Float]) {
            self.index = index
            self.lowerFrequency = lowerFrequency
            self.upperFrequency = upperFrequency
            self.values = values
        }
    }

    
    /// 轉換後的頻帶資料
    struct Band {
        
        public let index: Int                   // bar 的索引
        public let lowerFrequency: Float        // 這個 bar 對應的最低頻率
        public let upperFrequency: Float        // 這個 bar 對應的最高頻率
        public let amplitude: Float             // 正規化後的振幅，範圍為 0...1
        
        public init(index: Int, lowerFrequency: Float, upperFrequency: Float, amplitude: Float) {
            self.index = index
            self.lowerFrequency = lowerFrequency
            self.upperFrequency = upperFrequency
            self.amplitude = amplitude
        }
    }
}
