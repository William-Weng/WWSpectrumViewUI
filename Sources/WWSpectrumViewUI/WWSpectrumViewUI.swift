//
//  WWSpectrumViewUI.swift
//  WWSpectrumViewUI
//
//  Created by William.Weng on 2026/6/3.
//

import SwiftUI

/// 頻譜分析結果的 SwiftUI 視覺化元件
public struct WWSpectrumViewUI: View {
    
    @ObservedObject var viewModel: WWSpectrumViewUI.ViewModel
    
    public let colorScheme: ColorScheme
    public let barStyle: BarStyle
    public let duration: TimeInterval
    
    /// 建立頻譜視覺化元件
    ///
    /// - Parameters:
    ///   - viewModel: 頻譜資料來源
    ///   - colorScheme: bar 使用的顏色方案，預設為 `.rainbow`
    ///   - barStyle: bar 的顯示樣式，預設為 `.glow`
    ///   - duration: 振幅變化動畫時間，預設為 `0.25` 秒
    public init(viewModel: WWSpectrumViewUI.ViewModel, colorScheme: ColorScheme = .rainbow, barStyle: BarStyle = .glow, duration: TimeInterval = 0.25) {
        
        self.viewModel = viewModel
        self.colorScheme = colorScheme
        self.barStyle = barStyle
        self.duration = duration
    }
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            let bands = viewModel.rawBands
            let barCount = bands.count
            let spacing: CGFloat = 4
            let usableWidth = max(geometry.size.width - CGFloat(max(barCount - 1, 0)) * spacing - 8, 0)
            let barWidth = barCount > 0 ? max(usableWidth / CGFloat(barCount), 3) : 0
            let availableHeight = geometry.size.height - 16
            
            HStack(alignment: .bottom, spacing: spacing) {
                
                ForEach(bands, id: \.index) { band in
                    makeBandView(with: .init(width: barWidth, height: availableHeight), band: band)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            .background(Color.clear)
        }
        .clipped()
    }
}

// MARK: - 小工具
private extension WWSpectrumViewUI {
    
    /// 根據 bar 尺寸與原始頻帶資料，建立對應的頻譜條視圖
    ///
    /// 這個方法會先根據 `BandRaw` 計算振幅，再換算出 bar 的顯示高度，最後交給 `BandView` 負責實際繪製
    func makeBandView(with barSize: CGSize, band: BandRaw) -> some View {
        
        let amplitude = bandAmplitude(band)
        let barHeight = max(barSize.height * amplitude, 3)
        
        return BandView(index: band.index, lowerFrequency: band.lowerFrequency, upperFrequency: band.upperFrequency, amplitude: amplitude, height: barHeight, width: barSize.width, colorScheme: colorScheme, duration: duration, style: barStyle)
    }
    
    /// 將原始頻帶資料轉換成正規化振幅
    ///
    /// 這個方法會先計算 RMS，再轉成 dB，最後將結果映射到 `0...1` 的範圍，供 UI 顯示使用。
    func bandAmplitude(_ band: BandRaw) -> CGFloat {
        
        guard !band.values.isEmpty else { return 0 }
        
        let rms = sqrt(band.values.map { $0 * $0 }.reduce(0, +) / Float(band.values.count))
        let db = 20 * log10(max(rms, 0.0001))
        let normalized = (db + 60) / 60
        
        return CGFloat(min(max(normalized, 0), 1))
    }
}
