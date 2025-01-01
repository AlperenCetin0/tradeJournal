//
//  Trade.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation

// MARK: - Trade Model
struct Trade: Identifiable, Codable {
    // MARK: - Properties
    var id: UUID
    var cryptoPair: String
    var entryPrice: Double
    var exitPrice: Double
    var quantity: Double
    var side: TradeSide
    var date: Date
    var notes: String
    var strategy: String
    var timeFrame: TimeFrame
    var stopLoss: Double
    var takeProfit: Double
    var fees: Double
    var leverage: Double
    var confidence: ConfidenceLevel
    var emotions: String
    var setupQuality: SetupQuality
    var marketCondition: MarketCondition
    
    // MARK: - Computed Properties
    var profitLoss: Double {
        let rawPL = calculateRawProfitLoss()
        let tradingFees = calculateTotalFees()
        return (rawPL * leverage) - tradingFees
    }
    
    var riskAmount: Double {
        abs(entryPrice - stopLoss) * quantity * leverage
    }
    
    var rewardAmount: Double {
        abs(takeProfit - entryPrice) * quantity * leverage
    }
    
    var riskRewardRatio: Double {
        riskAmount == 0 ? 0 : rewardAmount / riskAmount
    }
    
    // MARK: - Private Methods
    private func calculateRawProfitLoss() -> Double {
        let priceDifference = side == .long ? exitPrice - entryPrice : entryPrice - exitPrice
        return priceDifference * quantity
    }
    
    private func calculateTotalFees() -> Double {
        let totalValue = (entryPrice + exitPrice) * quantity
        return (fees / 100) * totalValue
    }
    
    // MARK: - Initialization
    init(id: UUID = UUID(),
         cryptoPair: String,
         entryPrice: Double,
         exitPrice: Double,
         quantity: Double,
         side: TradeSide,
         date: Date = Date(),
         notes: String = "",
         strategy: String = "",
         timeFrame: TimeFrame = .H1,
         stopLoss: Double,
         takeProfit: Double,
         fees: Double = 0.1,
         leverage: Double = 1,
         confidence: ConfidenceLevel = .medium,
         emotions: String = "",
         setupQuality: SetupQuality = .good,
         marketCondition: MarketCondition = .neutral) {
        self.id = id
        self.cryptoPair = cryptoPair
        self.entryPrice = entryPrice
        self.exitPrice = exitPrice
        self.quantity = quantity
        self.side = side
        self.date = date
        self.notes = notes
        self.strategy = strategy
        self.timeFrame = timeFrame
        self.stopLoss = stopLoss
        self.takeProfit = takeProfit
        self.fees = fees
        self.leverage = leverage
        self.confidence = confidence
        self.emotions = emotions
        self.setupQuality = setupQuality
        self.marketCondition = marketCondition
    }
}

// MARK: - Trade Enums
enum TradeSide: String, Codable, CaseIterable {
    case long = "Long"
    case short = "Short"
}

enum TimeFrame: String, Codable, CaseIterable {
    case M1 = "1m"
    case M5 = "5m"
    case M15 = "15m"
    case M30 = "30m"
    case H1 = "1h"
    case H4 = "4h"
    case D1 = "1d"
    case W1 = "1w"
}

enum ConfidenceLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum SetupQuality: String, Codable, CaseIterable {
    case poor = "Poor"
    case good = "Good"
    case excellent = "Excellent"
}

enum MarketCondition: String, Codable, CaseIterable {
    case bearish = "Bearish"
    case neutral = "Neutral"
    case bullish = "Bullish"
}
