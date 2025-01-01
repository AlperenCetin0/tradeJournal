//
//  StatsCardView.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - StatItemView
private struct StatItemView: View {
    let title: String
    let value: String
    let condition: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(condition ? .green : .red)
        }
    }
}

// MARK: - StatsCardView
public struct StatsCardView: View {
    // MARK: - Properties
    let totalPL: Double
    let winRate: Double
    let profitFactor: Double
    let avgRR: Double
    
    // MARK: - Initialization
    public init(
        totalPL: Double,
        winRate: Double,
        profitFactor: Double,
        avgRR: Double
    ) {
        self.totalPL = totalPL
        self.winRate = winRate
        self.profitFactor = profitFactor
        self.avgRR = avgRR
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                StatItemView(title: "Total P/L",
                            value: String(format: "$%.2f", totalPL),
                            condition: totalPL >= 0)
                
                StatItemView(title: "Win Rate",
                            value: String(format: "%.1f%%", winRate),
                            condition: winRate >= 50)
            }
            
            HStack(spacing: 40) {
                StatItemView(title: "Profit Factor",
                            value: String(format: "%.2f", profitFactor),
                            condition: profitFactor >= 1.5)
                
                StatItemView(title: "Avg R:R",
                            value: String(format: "%.2f", avgRR),
                            condition: avgRR >= 2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
