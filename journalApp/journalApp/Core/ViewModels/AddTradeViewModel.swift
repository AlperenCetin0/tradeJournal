//
//  AddTradeViewModel.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation

// MARK: - AddTradeViewModel
class AddTradeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cryptoPair = ""
    @Published var entryPrice = ""
    @Published var exitPrice = ""
    @Published var quantity = ""
    @Published var side = TradeSide.long
    @Published var notes = ""
    @Published var strategy = ""
    @Published var stopLoss = ""
    @Published var takeProfit = ""
    @Published var fees = "0"
    @Published var leverage = "1"
    @Published var timeFrame = TimeFrame.H1
    @Published var confidence = ConfidenceLevel.medium
    @Published var emotions = ""
    @Published var setupQuality = SetupQuality.good
    @Published var marketCondition = MarketCondition.neutral
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Methods
    func createTrade() -> Trade? {
        guard validateInput() else { return nil }
        
        guard let entryPriceDouble = Double(entryPrice),
              let exitPriceDouble = Double(exitPrice),
              let quantityDouble = Double(quantity),
              let stopLossDouble = Double(stopLoss),
              let takeProfitDouble = Double(takeProfit),
              let feesDouble = Double(fees),
              let leverageDouble = Double(leverage) else {
            showError(message: "Please enter valid numeric values")
            return nil
        }
        
        return Trade(
            cryptoPair: cryptoPair,
            entryPrice: entryPriceDouble,
            exitPrice: exitPriceDouble,
            quantity: quantityDouble,
            side: side,
            notes: notes,
            strategy: strategy,
            timeFrame: timeFrame,
            stopLoss: stopLossDouble,
            takeProfit: takeProfitDouble,
            fees: feesDouble,
            leverage: leverageDouble,
            confidence: confidence,
            emotions: emotions,
            setupQuality: setupQuality,
            marketCondition: marketCondition
        )
    }
    
    private func validateInput() -> Bool {
        if cryptoPair.isEmpty {
            showError(message: "Please enter a crypto pair")
            return false
        }
        if entryPrice.isEmpty || exitPrice.isEmpty || quantity.isEmpty {
            showError(message: "Please fill in all required trade details")
            return false
        }
        if stopLoss.isEmpty || takeProfit.isEmpty {
            showError(message: "Stop Loss and Take Profit are required")
            return false
        }
        return true
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
