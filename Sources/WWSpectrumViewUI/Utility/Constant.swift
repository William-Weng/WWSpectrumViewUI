//
//  Constant.swift
//  WWSpectrumViewUI
//
//  Created by William.Weng on 2026/6/3.
//

import SwiftUI

// MARK: - enum
public extension WWSpectrumViewUI {
    
    /// 頻譜條的外觀樣式 => 用來控制每一根 bar 的形狀與發光效果
    enum BarStyle {
        
        case rounded                // 圓角條狀
        case sharp                  // 俐落的直角條狀
        case glow                   // 帶有發光效果的條狀
        case gradient               // 由下往上漸層的條狀
    }
    
    /// 頻譜條的顏色方案 => 用來決定每一根 bar 的顏色分布方式
    enum ColorScheme {
        
        case rainbow                // 彩虹色漸層
        case fire                   // 火焰色系
        case ocean                  // 海洋色系
        case neon                   // 高飽和霓虹色系
        case sunset                 // 日落色系
        case matrix                 // 綠色矩陣風格
        case custom([Color])        // 自訂顏色陣列
    }
}

// MARK: - WWSpectrumViewUI.ColorScheme
extension WWSpectrumViewUI.ColorScheme {
    
    /// 根據 bar 的索引與振幅，計算對應的顏色
    ///
    /// 顏色會依據目前的色彩方案、bar 在整體中的相對位置，以及 bar 的振幅做動態調整，以產生更自然的頻譜視覺效果
    ///
    /// - Parameters:
    ///   - band: 目前要計算顏色的頻譜 band
    ///   - totalBars: bar 的總數，用來推算相對位置
    /// - Returns: 對應的顏色
    func color(for band: WWSpectrumViewUI.Band, totalBars: Int) -> Color {
        
        let position = Float(band.index) / Float(totalBars - 1)
        let amplitude = band.amplitude
        
        switch self {
        case .rainbow: return rainbowScheme(with: position, amplitude: amplitude)
        case .fire: return fireScheme(with: position, amplitude: amplitude)
        case .ocean: return oceanScheme(with: position, amplitude: amplitude)
        case .neon: return neonScheme(with: position, amplitude: amplitude)
        case .sunset: return sunsetScheme(with: position, amplitude: amplitude)
        case .matrix: return matrixScheme(with: position, amplitude: amplitude)
        case .custom(let colors): return customScheme(with: position, colors: colors)
        }
    }
}

// MARK: - WWSpectrumViewUI.ColorScheme
private extension WWSpectrumViewUI.ColorScheme {
    
    /// 彩虹色系 => 顏色會依據 bar 的相對位置改變色相，並用振幅微調飽和度
    func rainbowScheme(with position: Float, amplitude: Float) -> Color {
        let hue = 1.0 - position
        return Color.initWith(hue: hue, saturation: 0.9 + amplitude * 0.1, brightness: 1.0)
    }
    
    /// 火焰色系 => 依據 bar 的位置分成紅、橘、黃三段，呈現火焰漸層感
    func fireScheme(with position: Float, amplitude: Float) -> Color {
        
        if position < 0.33 {
            return Color.initWith(red: position * 3, green: 0, blue: 0)
        }
        
        if position < 0.66 {
            let t = (position - 0.33) * 3
            return Color.initWith(red: 1, green: t * amplitude, blue: 0)
        }
        
        let t = (position - 0.66) * 3
        return Color.initWith(red: 1, green: 1, blue: t * 0.5)
    }
    
    /// 海洋色系 => 以藍綠色調為主，並用振幅調整飽和度與亮度
    func oceanScheme(with position: Float, amplitude: Float) -> Color {
        let hue = 0.6 - position * 0.4
        return Color.initWith(hue: hue, saturation: 0.7 + amplitude * 0.3, brightness: 0.5 + amplitude * 0.5)
    }
    
    /// 霓虹色系 => 使用高飽和、高亮度的顏色，呈現強烈的視覺效果
    func neonScheme(with position: Float, amplitude: Float) -> Color {
        let hue = 0.8 - position * 0.4
        return Color.initWith(hue: hue, saturation: 1.0, brightness: 1.0)
    }
    
    /// 日落色系 => 前半段偏紫紅，後半段逐漸轉為橘黃
    func sunsetScheme(with position: Float, amplitude: Float) -> Color {
        
        if position < 0.5 {
            let t = position * 2
            return Color.initWith(red: 0.5 + t * 0.5, green: t * 0.3, blue: 0.5 - t * 0.5)
        }
        
        let t = (position - 0.5) * 2
        return Color.initWith(red: 1, green: 0.5 + t * 0.5, blue: 0)
    }
    
    /// 綠色矩陣風格 => 依據振幅調整綠色強度，產生類似終端機風格的效果
    func matrixScheme(with position: Float, amplitude: Float) -> Color {
        return Color.initWith(red: 0, green: amplitude, blue: 0)
    }
    
    /// 自訂色彩陣列 => 依據 bar 的相對位置，從指定的顏色列表中挑選對應顏色
    func customScheme(with position: Float, colors: [Color]) -> Color {
        let colorIndex = min(Int(position * Float(colors.count - 1)), colors.count - 1)
        return colors[colorIndex]
    }
}
