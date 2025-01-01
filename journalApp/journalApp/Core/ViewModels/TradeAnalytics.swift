//
//  TradeAnalytics.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation

// MARK: - Trade Analytics
struct TradeAnalytics {
    let trades: [Trade]
    
    var totalProfitLoss: Double {
        trades.reduce(0) { $0 + $1.profitLoss }
    }
    
    var winRate: Double {
        let winningTrades = trades.filter { $0.profitLoss > 0 }.count
        return trades.isEmpty ? 0 : Double(winningTrades) / Double(trades.count) * 100
    }
}
