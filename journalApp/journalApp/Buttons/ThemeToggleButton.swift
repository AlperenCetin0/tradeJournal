//
//  ThemeToggleButton.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

struct ThemeToggleButton: View {
    @Binding var isDarkMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            isDarkMode.toggle()
            action()
        }) {
            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                .foregroundColor(.primary)
        }
    }
}
