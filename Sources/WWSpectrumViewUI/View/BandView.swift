//
//  BandView.swift
//  WWSpectrumViewUI
//
//  Created by William.Weng on 2026/6/3.
//

import SwiftUI

/// 頻譜視覺化中的單一View
extension WWSpectrumViewUI {
    
    /// 這個 view 會根據 band 的頻率範圍、振幅、顏色方案與樣式，將一筆頻帶資料畫成一根可動畫的頻譜條
    struct BandView: View {
        
        let index: Int                      // bar 的索引
        let lowerFrequency: Float           // 這個 bar 對應的最低頻率
        let upperFrequency: Float           // 這個 bar 對應的最高頻率
        let amplitude: CGFloat              // 正規化後的振幅，範圍為 `0...1`
        let height: CGFloat                 // bar 的顯示高度
        let width: CGFloat                  // bar 的顯示寬度
        let colorScheme: ColorScheme        // bar 使用的顏色方案
        let duration: TimeInterval          // 動畫持續時間
        let style: BarStyle                 // bar 的外觀樣式
        
        var body: some View {
            
            ZStack(alignment: .bottom) {
                makeView(with: style)
            }
            .animation(.easeOut(duration: duration), value: amplitude)
        }
    }
}

// MARK: - 小工具
private extension WWSpectrumViewUI.BandView {
    
    /// 依照指定樣式建立 bar 的實際外觀
    ///
    /// 這個方法會先把目前的 band 資料轉成 `Band`，再依據 `ColorScheme` 與 `BarStyle` 決定要畫成圓角、發光、漸層或銳角樣式
    func makeView(with style: WWSpectrumViewUI.BarStyle) -> some View {
        
        let band = WWSpectrumViewUI.Band(index: index, lowerFrequency: lowerFrequency, upperFrequency: upperFrequency, amplitude: Float(amplitude))
        let barColor = colorScheme.color(for: band, totalBars: 48)
        let clampedHeight = max(height, 2)
        let base = RoundedRectangle(cornerRadius: min(width * 0.45, 6), style: .continuous)
        
        return ZStack(alignment: .center) {
            
            switch style {
            case .rounded:
                base.fill(barColor)
                    .frame(width: width, height: clampedHeight)
            case .glow:
                base.fill(barColor)
                    .frame(width: width, height: clampedHeight)
                    .shadow(color: barColor.opacity(0.16), radius: 10, x: 0, y: 0)
                    .shadow(color: barColor.opacity(0.22), radius: 4, x: 0, y: 0)
            case .gradient:
                base.fill(
                    LinearGradient(
                        colors: [barColor.opacity(1), barColor.opacity(0.65), barColor.opacity(0.25)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: width, height: clampedHeight)
            case .sharp:
                Rectangle()
                    .fill(barColor)
                    .frame(width: width, height: clampedHeight)
            }
        }
    }
}
