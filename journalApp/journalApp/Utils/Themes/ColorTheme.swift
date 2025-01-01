//
//  ColorTheme.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - ColorTheme
struct ColorTheme {
    let accent: Color
    let background: Color
    let card: Color
    let green: Color
    let red: Color
    let secondaryText: Color
    
    // Custom trading specific colors
    let profit: Color
    let loss: Color
    let neutral: Color
    
    static let `default` = ColorTheme(
        accent: Color("AccentColor"),
        background: Color("BackgroundColor"),
        card: Color("CardColor"),
        green: Color("GreenColor"),
        red: Color("RedColor"),
        secondaryText: Color("SecondaryTextColor"),
        profit: Color("GreenColor"),
        loss: Color("RedColor"),
        neutral: Color(.systemGray)
    )
}

// MARK: - Color Extensions
extension Color {
    static let theme = ColorTheme.default
}

// MARK: - View Extensions
extension View {
    func profitLossColor(_ value: Double) -> some View {
        foregroundColor(value >= 0 ? Color.theme.profit : Color.theme.loss)
    }
    
    func conditionalColor(_ condition: Bool, positive: Color = Color.theme.profit, negative: Color = Color.theme.loss) -> some View {
        foregroundColor(condition ? positive : negative)
    }
}
