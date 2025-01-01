//
//  TradeDetailView.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - TradeDetailView
struct TradeDetailView: View {
    // MARK: - Properties
    let trade: Trade
    
    // MARK: - Body
    var body: some View {
        List {
            Section(header: Text("Trade Details")) {
                DetailRow(title: "Crypto Pair", value: trade.cryptoPair)
                DetailRow(title: "Entry Price", value: String(format: "$%.2f", trade.entryPrice))
                DetailRow(title: "Exit Price", value: String(format: "$%.2f", trade.exitPrice))
                DetailRow(title: "Quantity", value: String(format: "%.4f", trade.quantity))
                DetailRow(title: "Side", value: trade.side.rawValue)
                DetailRow(title: "Date", value: trade.date.formatted())
            }
            
            Section(header: Text("Risk Management")) {
                DetailRow(title: "Stop Loss", value: String(format: "$%.2f", trade.stopLoss))
                DetailRow(title: "Take Profit", value: String(format: "$%.2f", trade.takeProfit))
                DetailRow(title: "Risk/Reward", value: String(format: "%.2f", trade.riskRewardRatio))
                DetailRow(title: "Leverage", value: String(format: "%.1fx", trade.leverage))
                DetailRow(title: "Fees", value: String(format: "%.2f%%", trade.fees))
            }
            
            Section(header: Text("Context")) {
                DetailRow(title: "Time Frame", value: trade.timeFrame.rawValue)
                DetailRow(title: "Strategy", value: trade.strategy)
                DetailRow(title: "Setup Quality", value: trade.setupQuality.rawValue)
                DetailRow(title: "Market Condition", value: trade.marketCondition.rawValue)
                DetailRow(title: "Confidence", value: trade.confidence.rawValue)
            }
            
            if !trade.emotions.isEmpty || !trade.notes.isEmpty {
                Section(header: Text("Additional Info")) {
                    if !trade.emotions.isEmpty {
                        DetailRow(title: "Emotions", value: trade.emotions)
                    }
                    if !trade.notes.isEmpty {
                        DetailRow(title: "Notes", value: trade.notes)
                    }
                }
            }
        }
        .navigationTitle(trade.cryptoPair)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - DetailRow
private struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}
