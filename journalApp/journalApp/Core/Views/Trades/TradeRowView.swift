//
//  TradeRowView.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - TradeRowView
struct TradeRowView: View {
    // MARK: - Properties
    let trade: Trade
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trade.cryptoPair)
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", trade.profitLoss))
                    .foregroundColor(trade.profitLoss >= 0 ? .green : .red)
                    .font(.headline)
            }
            
            HStack {
                Text(trade.side.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(trade.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !trade.strategy.isEmpty {
                Text(trade.strategy)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 4)
    }
}
