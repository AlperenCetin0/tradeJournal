//
//  AdditionalInfoSection.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - AdditionalInfoSection
struct AdditionalInfoSection: View {
    @ObservedObject var viewModel: AddTradeViewModel
    
    var body: some View {
        Section(header: Text("Additional Information")) {
            TextField("Strategy", text: $viewModel.strategy)
            TextField("Emotions/Psychology", text: $viewModel.emotions)
            TextEditor(text: $viewModel.notes)
                .frame(height: 100)
        }
    }
}
