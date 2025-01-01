//
//  TradeListViewModel.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation
import CoreData

// MARK: - TradeListViewModel
final class TradeListViewModel: ObservableObject {
    // MARK: - Properties
    @Published var dateFilter: DateFilter = .allTime
    @Published var symbolStats: [String: SymbolStats] = [:]
    @Published private(set) var trades: [Trade] = []
    @Published var isLoading: Bool = false
    @Published private(set) var hasMoreData: Bool = true
    
    private let storageManager: TradeStorageManager
    private let pageSize = 50
    private var currentPage = 0
    
    // MARK: - Enums
    enum DateFilter: String, CaseIterable {
        case last7Days = "Last 7 Days"
        case last30Days = "Last 30 Days"
        case last3Months = "Last 3 Months"
        case last6Months = "Last 6 Months"
        case lastYear = "Last Year"
        case allTime = "All Time"
        
        var daysBack: Int? {
            switch self {
            case .last7Days: return 7
            case .last30Days: return 30
            case .last3Months: return 90
            case .last6Months: return 180
            case .lastYear: return 365
            case .allTime: return nil
            }
        }
    }
    
    // MARK: - Symbol Statistics Structure
    struct SymbolStats {
        let totalTrades: Int
        let winRate: Double
        let avgProfit: Double
        let totalPL: Double
    }
    
    // MARK: - Initialization
    init(storageManager: TradeStorageManager = .shared) {
        self.storageManager = storageManager
        loadInitialData()
    }
    
    // MARK: - Setup
    private func loadInitialData() {
        storageManager.loadTrades()
        trades = storageManager.trades
        
        if trades.isEmpty {
            addSampleData()
        }
        
        hasMoreData = trades.count >= pageSize
        updateSymbolStats()
    }
    
    // MARK: - Data Loading
    private func loadMoreTradesIfNeeded() {
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        currentPage += 1
        
        // Simulated loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Update loading state
            self.isLoading = false
            self.hasMoreData = false // For demo purposes
            self.updateSymbolStats()
        }
    }
    
    func loadMoreIfNeeded(currentItem trade: Trade) {
        guard !isLoading,
              let index = trades.firstIndex(where: { $0.id == trade.id }),
              index >= trades.count - 5 else { return }
        
        isLoading = true
        let offset = trades.count
        storageManager.loadTrades()
        trades = storageManager.trades
        isLoading = false
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.hasMoreData = false // For demo purposes
        }
    }
    
    // MARK: - Trade Management
    func addTrade(_ trade: Trade) {
        storageManager.saveTrade(trade)
        trades = storageManager.trades
        updateSymbolStats(for: trade.cryptoPair)
    }
    
    func deleteTrade(_ trade: Trade) {
        storageManager.deleteTrade(trade)
        updateSymbolStats(for: trade.cryptoPair)
    }
    
    func removeTrade(at offsets: IndexSet) {
        storageManager.removeTrades(atOffsets: offsets)
    }
    
    private func loadTrades() {
        storageManager.loadTrades()
    }
    
    private func addSampleData() {
        let sampleTrades = [
            Trade(cryptoPair: "BTC/USDT",
                  entryPrice: 42000,
                  exitPrice: 43500,
                  quantity: 0.1,
                  side: .long,
                  notes: "Strong trend following",
                  strategy: "Trend Following",
                  stopLoss: 41000,
                  takeProfit: 44000),
            Trade(cryptoPair: "ETH/USDT",
                  entryPrice: 2200,
                  exitPrice: 2150,
                  quantity: 1,
                  side: .short,
                  notes: "Resistance rejection",
                  strategy: "Price Action",
                  stopLoss: 2250,
                  takeProfit: 2100)
        ]
        storageManager.saveTrades(sampleTrades)
    }
    
    // MARK: - Symbol Analysis
    private func updateSymbolStats(for symbol: String? = nil) {
        let symbols = symbol.map { [$0] } ?? Array(Set(trades.map { $0.cryptoPair }))
        
        for symbol in symbols {
            let symbolTrades = storageManager.getTradesBySymbol(symbol)
            guard !symbolTrades.isEmpty else { continue }
            
            let wins = symbolTrades.filter { $0.profitLoss > 0 }.count
            let winRate = Double(wins) / Double(symbolTrades.count) * 100
            let avgProfit = symbolTrades.reduce(0.0) { $0 + $1.profitLoss } / Double(symbolTrades.count)
            let totalPL = symbolTrades.reduce(0.0) { $0 + $1.profitLoss }
            
            symbolStats[symbol] = SymbolStats(
                totalTrades: symbolTrades.count,
                winRate: winRate,
                avgProfit: avgProfit,
                totalPL: totalPL
            )
        }
    }
    
    func groupTradesBySymbol() -> [(symbol: String, stats: SymbolStats)] {
        return symbolStats
            .map { (symbol: $0.key, stats: $0.value) }
            .sorted { $0.stats.totalTrades > $1.stats.totalTrades }
            .prefix(10)
            .map { $0 }
    }
    
    func getSymbolStats(for symbol: String) -> SymbolStats? {
        return symbolStats[symbol]
    }
    
    // MARK: - Computed Properties
    var filteredTrades: [Trade] {
        guard let days = dateFilter.daysBack else { return trades }
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return trades.filter { $0.date >= cutoffDate }
    }
    
    // MARK: - Statistics
    var totalProfitLoss: Double {
        trades.reduce(0) { $0 + $1.profitLoss }
    }
    
    var winRate: Double {
        let winningTrades = trades.filter { $0.profitLoss > 0 }.count
        return trades.isEmpty ? 0 : (Double(winningTrades) / Double(trades.count)) * 100
    }
    
    var profitFactor: Double {
        let grossProfit = trades.filter { $0.profitLoss > 0 }.reduce(0) { $0 + $1.profitLoss }
        let grossLoss = abs(trades.filter { $0.profitLoss < 0 }.reduce(0) { $0 + $1.profitLoss })
        return grossLoss == 0 ? 0 : grossProfit / grossLoss
    }
    
    var averageRiskRewardRatio: Double {
        trades.isEmpty ? 0 : trades.reduce(0) { $0 + $1.riskRewardRatio } / Double(trades.count)
    }
}

extension TradeListViewModel {
    func checkIfNeedsMoreData(currentItem trade: Trade) {
        guard let index = trades.firstIndex(where: { $0.id == trade.id }),
              index >= trades.count - 5 else { return }
        loadMoreData()
    }
}
