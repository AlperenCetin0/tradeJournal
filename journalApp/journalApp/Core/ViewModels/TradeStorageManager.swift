//
//  TradeStorageManager.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation
import CoreData

// MARK: - TradeStorageManager
final class TradeStorageManager: ObservableObject {
    // MARK: - Properties
    static let shared = TradeStorageManager()
    private let pageSize = 50
    
    // MARK: - Core Data
    private let container: NSPersistentContainer
    private let containerName = "TradeJournal"
    private let entityName = "TradeEntity"
    
    @Published private(set) var trades: [Trade] = []
    @Published private(set) var loadingState: Bool = false
    
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        
        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Initialize Core Data stack
        container = NSPersistentContainer(name: containerName)
        
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.persistentStoreDescriptions = [storeDescription]
        
        // Load persistent stores
        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
        
        // Configure the persistent store
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Initialize with empty state
        loadTrades()
    }
    
    // MARK: - Trade Loading
    func loadTrades(offset: Int = 0, limit: Int = 50) {
        loadingState = true
        
        let request = NSFetchRequest<TradeEntity>(entityName: entityName)
        request.fetchOffset = offset
        request.fetchLimit = limit
        request.fetchBatchSize = pageSize
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let result = try container.viewContext.fetch(request)
            let newTrades = result.compactMap { $0.toTrade() }
            
            if offset == 0 {
                trades = newTrades
            } else {
                trades.append(contentsOf: newTrades)
            }
        } catch {
            print("Error loading trades: \(error)")
        }
        
        loadingState = false
    }
    
    func loadMoreTrades() {
        guard !loadingState else { return }
        loadingState = true
        
        let request = NSFetchRequest<TradeEntity>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchOffset = trades.count
        request.fetchLimit = pageSize
        
        do {
            let result = try container.viewContext.fetch(request)
            let newTrades = result.compactMap { $0.toTrade() }
            trades.append(contentsOf: newTrades)
        } catch {
            print("Error loading more trades: \(error)")
        }
        
        loadingState = false
    }
    
    // MARK: - Trade Management
    func saveTrade(_ trade: Trade) {
        loadingState = true
        
        container.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let entity = TradeEntity(context: context)
            entity.fromTrade(trade)
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.loadTrades()
                    self.loadingState = false
                }
            } catch {
                print("Error saving trade: \(error)")
                DispatchQueue.main.async {
                    self.loadingState = false
                }
            }
        }
    }
    
    func saveTrades(_ trades: [Trade]) {
        loadingState = true
        
        container.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            for trade in trades {
                let entity = TradeEntity(context: context)
                entity.fromTrade(trade)
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.loadTrades()
                    self.loadingState = false
                }
            } catch {
                print("Error saving trades: \(error)")
                DispatchQueue.main.async {
                    self.loadingState = false
                }
            }
        }
    }
    
    func deleteTrade(_ trade: Trade) {
        loadingState = true
        
        container.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let request = NSFetchRequest<TradeEntity>(entityName: self.entityName)
            request.predicate = NSPredicate(format: "id == %@", trade.id as CVarArg)
            request.fetchLimit = 1
            
            do {
                let result = try context.fetch(request)
                if let entity = result.first {
                    context.delete(entity)
                    try context.save()
                    
                    DispatchQueue.main.async {
                        self.loadTrades()
                        self.loadingState = false
                    }
                }
            } catch {
                print("Error deleting trade: \(error)")
                DispatchQueue.main.async {
                    self.loadingState = false
                }
            }
        }
    }
    
    func removeTrades(atOffsets offsets: IndexSet) {
        loadingState = true
        let tradesToRemove = offsets.map { trades[$0] }
        
        for trade in tradesToRemove {
            deleteTrade(trade)
        }
        loadingState = false
    }
    
    // MARK: - Filtered Queries
    func getTradesBySymbol(_ symbol: String) -> [Trade] {
        let request = NSFetchRequest<TradeEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "cryptoPair == %@", symbol)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.compactMap { $0.toTrade() }
        } catch {
            print("Error fetching trades by symbol: \(error)")
            return []
        }
    }
    
    func loadMore(offset: Int, completion: @escaping (Bool) -> Void) {
        loadingState = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadingState = false
            completion(true)
        }
    }
}

// MARK: - TradeEntity Extension
extension TradeEntity {
    func toTrade() -> Trade? {
        guard let id = id,
              let cryptoPair = cryptoPair,
              let side = side,
              let date = date,
              let timeFrame = timeFrame,
              let confidence = confidence,
              let setupQuality = setupQuality,
              let marketCondition = marketCondition else {
            return nil
        }
        
        return Trade(
            id: id,
            cryptoPair: cryptoPair,
            entryPrice: entryPrice,
            exitPrice: exitPrice,
            quantity: quantity,
            side: TradeSide(rawValue: side) ?? .long,
            date: date,
            notes: notes ?? "",
            strategy: strategy ?? "",
            timeFrame: TimeFrame(rawValue: timeFrame) ?? .H1,
            stopLoss: stopLoss,
            takeProfit: takeProfit,
            fees: fees,
            leverage: leverage,
            confidence: ConfidenceLevel(rawValue: confidence) ?? .medium,
            emotions: emotions ?? "",
            setupQuality: SetupQuality(rawValue: setupQuality) ?? .good,
            marketCondition: MarketCondition(rawValue: marketCondition) ?? .neutral
        )
    }
    
    func fromTrade(_ trade: Trade) {
        id = trade.id
        cryptoPair = trade.cryptoPair
        entryPrice = trade.entryPrice
        exitPrice = trade.exitPrice
        quantity = trade.quantity
        side = trade.side.rawValue
        date = trade.date
        notes = trade.notes
        strategy = trade.strategy
        timeFrame = trade.timeFrame.rawValue
        stopLoss = trade.stopLoss
        takeProfit = trade.takeProfit
        fees = trade.fees
        leverage = trade.leverage
        confidence = trade.confidence.rawValue
        emotions = trade.emotions
        setupQuality = trade.setupQuality.rawValue
        marketCondition = trade.marketCondition.rawValue
    }
}
