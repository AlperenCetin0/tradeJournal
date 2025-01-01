//
//  DecimalField.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

// MARK: - DecimalField
struct DecimalField: View {
    let title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.decimalPad)
            .onChange(of: text) { newValue in
                // Only allow numbers and one decimal point
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if filtered != newValue {
                    text = filtered
                }
                // Ensure only one decimal point
                if filtered.filter({ $0 == "." }).count > 1 {
                    text = String(filtered.prefix(while: { $0 != "." })) + "."
                        + String(filtered.suffix(from: filtered.index(after: filtered.firstIndex(of: ".")!)).filter { $0 != "." })
                }
            }
    }
}
