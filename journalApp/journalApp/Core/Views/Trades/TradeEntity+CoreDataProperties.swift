//
//  TradeEntity+CoreDataProperties.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import Foundation
import CoreData

extension TradeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TradeEntity> {
        return NSFetchRequest<TradeEntity>(entityName: "TradeEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var cryptoPair: String?
    @NSManaged public var entryPrice: Double
    @NSManaged public var exitPrice: Double
    @NSManaged public var quantity: Double
    @NSManaged public var side: String?
    @NSManaged public var date: Date?
    @NSManaged public var notes: String?
    @NSManaged public var strategy: String?
    @NSManaged public var timeFrame: String?
    @NSManaged public var stopLoss: Double
    @NSManaged public var takeProfit: Double
    @NSManaged public var fees: Double
    @NSManaged public var leverage: Double
    @NSManaged public var confidence: String?
    @NSManaged public var emotions: String?
    @NSManaged public var setupQuality: String?
    @NSManaged public var marketCondition: String?
}

extension TradeEntity : Identifiable {
    // No additional code needed
}
