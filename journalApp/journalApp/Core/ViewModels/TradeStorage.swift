//
//  TradeStorage.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation

// MARK: - Trade Storage Protocol
protocol TradeStorageType {
    func saveTrades(_ trades: [Trade])
    func loadTrades() -> [Trade]
}

// MARK: - Trade Storage Implementation
final class TradeStorage: TradeStorageType {
    // MARK: - Properties
    private let tradesKey = "savedTrades"
    
    // MARK: - Singleton
    static let shared = TradeStorage()
    private init() {}
    
    // MARK: - Methods
    func saveTrades(_ trades: [Trade]) {
        if let encodedData = try? JSONEncoder().encode(trades) {
            UserDefaults.standard.set(encodedData, forKey: tradesKey)
        }
    }
    
    func loadTrades() -> [Trade] {
        guard let data = UserDefaults.standard.data(forKey: tradesKey),
              let trades = try? JSONDecoder().decode([Trade].self, from: data) else {
            return []
        }
        return trades
    }
}
