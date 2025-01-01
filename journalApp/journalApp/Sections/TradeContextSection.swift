//
//  TradeContextSection.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - TradeContextSection
struct TradeContextSection: View {
    @ObservedObject var viewModel: AddTradeViewModel
    
    var body: some View {
        Section(header: Text("Trade Context")) {
            Picker("Time Frame", selection: $viewModel.timeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { frame in
                    Text(frame.rawValue).tag(frame)
                }
            }
            
            Picker("Setup Quality", selection: $viewModel.setupQuality) {
                ForEach(SetupQuality.allCases, id: \.self) { quality in
                    Text(quality.rawValue).tag(quality)
                }
            }
            
            Picker("Market Condition", selection: $viewModel.marketCondition) {
                ForEach(MarketCondition.allCases, id: \.self) { condition in
                    Text(condition.rawValue).tag(condition)
                }
            }
            
            Picker("Confidence Level", selection: $viewModel.confidence) {
                ForEach(ConfidenceLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
        }
    }
}

// End of file. No additional code.
