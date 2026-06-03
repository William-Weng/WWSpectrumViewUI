//
//  Extension.swift
//  WWSpectrumViewUI
//
//  Created by William.Weng on 2026/6/3.
//

import SwiftUI

// MARK: - Color
extension Color {
    
    /// 使用 `Float` 也能建立 `Color`
    static func initWith(red: Float, green: Float, blue: Float) -> Color {
        Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
    
    /// 使用 `Float` 也能建立 `Color`
    static func initWith(hue: Float, saturation: Float, brightness: Float) -> Color {
        Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(saturation))
    }
}
