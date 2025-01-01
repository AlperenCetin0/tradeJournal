//
//  RiskManagementSection.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - RiskManagementSection
struct RiskManagementSection: View {
    @ObservedObject var viewModel: AddTradeViewModel
    
    var body: some View {
        Section(header: Text("Risk Management")) {
            DecimalField("Stop Loss", text: $viewModel.stopLoss)
            DecimalField("Take Profit", text: $viewModel.takeProfit)
            DecimalField("Fees (%)", text: $viewModel.fees)
            DecimalField("Leverage", text: $viewModel.leverage)
        }
    }
}
