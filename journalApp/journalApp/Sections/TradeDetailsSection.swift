//
//  TradeDetailsSection.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - TradeDetailsSection
struct TradeDetailsSection: View {
    @ObservedObject var viewModel: AddTradeViewModel
    
    var body: some View {
        Section(header: Text("Trade Details")) {
            TextField("Crypto Pair (e.g., BTC/USDT)", text: $viewModel.cryptoPair)
                .autocapitalization(.allCharacters)
            
            DecimalField("Entry Price", text: $viewModel.entryPrice)
            DecimalField("Exit Price", text: $viewModel.exitPrice)
            DecimalField("Quantity", text: $viewModel.quantity)
            
            Picker("Side", selection: $viewModel.side) {
                Text("Long").tag(TradeSide.long)
                Text("Short").tag(TradeSide.short)
            }
        }
    }
}
