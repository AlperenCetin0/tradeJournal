//
//  AddTradeView.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - AddTradeView
struct AddTradeView: View {
    // MARK: - Properties
    var tradeListViewModel: TradeListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var cryptoPair = ""
    @State private var entryPrice = ""
    @State private var exitPrice = ""
    @State private var quantity = ""
    @State private var side = TradeSide.long
    @State private var stopLoss = ""
    @State private var takeProfit = ""
    
    // MARK: - Body
    var body: some View {
        Form {
            Section(header: Text("Trade Details")) {
                TextField("Crypto Pair", text: $cryptoPair)
                TextField("Entry Price", text: $entryPrice)
                TextField("Exit Price", text: $exitPrice)
                TextField("Quantity", text: $quantity)
                Picker("Side", selection: $side) {
                    ForEach(TradeSide.allCases, id: \.self) { side in
                        Text(side.rawValue).tag(side)
                    }
                }
                TextField("Stop Loss", text: $stopLoss)
                TextField("Take Profit", text: $takeProfit)
            }
        }
        .navigationTitle("Add Trade")
        .navigationBarItems(trailing: Button("Save") {
            saveTrade()
        })
    }
    
    // MARK: - Private Methods
    private func saveTrade() {
        let trade = Trade(
            cryptoPair: cryptoPair,
            entryPrice: Double(entryPrice) ?? 0,
            exitPrice: Double(exitPrice) ?? 0,
            quantity: Double(quantity) ?? 0,
            side: side,
            stopLoss: Double(stopLoss) ?? 0,
            takeProfit: Double(takeProfit) ?? 0
        )
        tradeListViewModel.addTrade(trade)
        dismiss()
    }
}
