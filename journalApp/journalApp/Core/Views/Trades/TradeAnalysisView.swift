//
//  TradeAnalysisView.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI
import Foundation
import Charts

// MARK: - Supporting Views
struct TradeStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Trade Analysis View
struct TradeAnalysisView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: TradeListViewModel
    
    @State private var showingDetailAnalysis = false
    @State private var selectedTimeFrame: TimeFrame = .H1
    @State private var selectedStrategy: String = "All"
    @State private var selectedPeriod: String = "Week"
    @State private var showBars = false
    
    private let periods = ["Week", "Month", "Quarter", "Year", "All Time"]
    
    private var filteredTrades: [Trade] {
        viewModel.trades.filter { trade in
            let timeFrameMatch = selectedTimeFrame == trade.timeFrame
            let strategyMatch = selectedStrategy == "All" || selectedStrategy == trade.strategy
            let periodMatch = isTradeInSelectedPeriod(trade.date)
            return timeFrameMatch && strategyMatch && periodMatch
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                filterSection
                summarySection
                
                Button(action: {
                    showingDetailAnalysis = true
                }) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                        Text("Detail Analysis")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Group {
                    EquityCurveView(trades: filteredTrades)
                    profitLossChartSection
                    winRateByStrategySection
                    winRateByTimeFrameSection
                    tradeDistributionSection
                }
                .id(viewModel.trades.count) // Force update when trades count changes
            }
            .padding()
        }
        .navigationTitle("Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDetailAnalysis) {
            NavigationView {
                AnalysisSection()
            }
        }
        .onAppear {
            showBars = true
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 10) {
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Strategy", selection: $selectedStrategy) {
                Text("All").tag("All")
                ForEach(Array(Set(viewModel.trades.map { $0.strategy })), id: \.self) { strategy in
                    Text(strategy).tag(strategy)
                }
            }
            .pickerStyle(.menu)
            
            Picker("Period", selection: $selectedPeriod) {
                ForEach(periods, id: \.self) { period in
                    Text(period).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
            TradeStatCard(title: "Total P/L", value: String(format: "$%.2f", calculateTotalPL()))
            TradeStatCard(title: "Win Rate", value: String(format: "%.1f%%", calculateWinRate()))
            TradeStatCard(title: "Avg Trade", value: String(format: "$%.2f", calculateAverageTradeAmount()))
            TradeStatCard(title: "Largest Win", value: String(format: "$%.2f", calculateLargestWin()))
            TradeStatCard(title: "Largest Loss", value: String(format: "$%.2f", calculateLargestLoss()))
            TradeStatCard(title: "Avg R:R", value: String(format: "%.2f", calculateAverageRR()))
        }
    }
    
    // MARK: - Chart Sections
    private var profitLossChartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profit/Loss Over Time")
                .font(.headline)
            
            Chart {
                ForEach(filteredTrades) { trade in
                    LineMark(
                        x: .value("Date", trade.date),
                        y: .value("P/L", trade.profitLoss)
                    )
                    .foregroundStyle(trade.profitLoss >= 0 ? .green : .red)
                }
            }
            .frame(height: 200)
        }
    }
    
    private var winRateByStrategySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Win Rate by Strategy")
                .font(.headline)
            
            Chart {
                ForEach(calculateStrategyStats()) { stat in
                    BarMark(
                        x: .value("Strategy", stat.name),
                        y: .value("Win Rate", showBars ? stat.winRate : 0)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showBars = true
                }
            }
            .onDisappear {
                showBars = false
            }
        }
    }
    
    private var winRateByTimeFrameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Win Rate by Time Frame")
                .font(.headline)
            
            Chart {
                ForEach(calculateTimeFrameStats()) { stat in
                    BarMark(
                        x: .value("Time Frame", stat.name),
                        y: .value("Win Rate", showBars ? stat.winRate : 0)
                    )
                    .foregroundStyle(.purple)
                }
            }
            .frame(height: 200)
        }
    }
    
    private var tradeDistributionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trade Distribution")
                .font(.headline)
            
            Chart {
                ForEach(calculateTradeDistribution()) { stat in
                    BarMark(
                        x: .value("Category", stat.name),
                        y: .value("Count", stat.count)
                    )
                    .foregroundStyle(.orange)
                    .annotation(position: .top) {
                        VStack(spacing: 4) {
                            Text("\(stat.count)")
                                .font(.caption)
                                .foregroundColor(.primary)
                            Text("\(Int(stat.winRate))%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            
            HStack(spacing: 20) {
                ForEach(calculateTradeDistribution()) { stat in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                        Text(stat.name)
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Analysis Models
    struct StatModel: Identifiable {
        let id = UUID()
        let name: String
        let winRate: Double
        let count: Int
    }
    
    // MARK: - Calculation Methods
    private func calculateTotalPL() -> Double {
        filteredTrades.reduce(0) { $0 + $1.profitLoss }
    }
    
    private func calculateWinRate() -> Double {
        let winningTrades = filteredTrades.filter { $0.profitLoss > 0 }.count
        return filteredTrades.isEmpty ? 0 : Double(winningTrades) / Double(filteredTrades.count) * 100
    }
    
    private func calculateAverageTradeAmount() -> Double {
        filteredTrades.isEmpty ? 0 : filteredTrades.reduce(0) { $0 + $1.profitLoss } / Double(filteredTrades.count)
    }
    
    private func calculateLargestWin() -> Double {
        let winningTrades = filteredTrades.filter { $0.profitLoss > 0 }
        return winningTrades.max(by: { $0.profitLoss < $1.profitLoss })?.profitLoss ?? 0
    }
    
    private func calculateLargestLoss() -> Double {
        let losingTrades = filteredTrades.filter { $0.profitLoss < 0 }
        return losingTrades.min(by: { $0.profitLoss < $1.profitLoss })?.profitLoss ?? 0
    }
    
    private func calculateAverageRR() -> Double {
        let tradesWithRR = filteredTrades.filter { $0.riskRewardRatio > 0 }
        return tradesWithRR.isEmpty ? 0 : tradesWithRR.reduce(0) { $0 + $1.riskRewardRatio } / Double(tradesWithRR.count)
    }
    
    private func calculateStrategyStats() -> [StatModel] {
        let groupedTrades = Dictionary(grouping: filteredTrades, by: { $0.strategy })
        return groupedTrades.compactMap { strategy, trades in
            guard !trades.isEmpty else { return nil }
            let winCount = trades.filter { $0.profitLoss > 0 }.count
            let winRate = Double(winCount) / Double(trades.count) * 100
            return StatModel(name: strategy, winRate: winRate, count: trades.count)
        }
    }
    
    private func calculateTimeFrameStats() -> [StatModel] {
        let groupedTrades = Dictionary(grouping: filteredTrades, by: { $0.timeFrame })
        return groupedTrades.compactMap { timeFrame, trades in
            guard !trades.isEmpty else { return nil }
            let winCount = trades.filter { $0.profitLoss > 0 }.count
            let winRate = Double(winCount) / Double(trades.count) * 100
            return StatModel(name: timeFrame.rawValue, winRate: winRate, count: trades.count)
        }
    }
    
    private func calculateTradeDistribution() -> [StatModel] {
        guard !filteredTrades.isEmpty else { return [] }
        
        let categories = [
            ("Large Win", { (trade: Trade) -> Bool in trade.profitLoss > 100 }),
            ("Small Win", { (trade: Trade) -> Bool in trade.profitLoss > 0 && trade.profitLoss <= 100 }),
            ("Small Loss", { (trade: Trade) -> Bool in trade.profitLoss < 0 && trade.profitLoss >= -100 }),
            ("Large Loss", { (trade: Trade) -> Bool in trade.profitLoss < -100 })
        ]
        
        return categories.map { category in
            let count = filteredTrades.filter(category.1).count
            let percentage = Double(count) / Double(filteredTrades.count) * 100
            return StatModel(name: category.0, winRate: percentage, count: count)
        }.filter { $0.count > 0 }  // Only show categories that have trades
    }
    
    // MARK: - Helper Methods
    private func isTradeInSelectedPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedPeriod {
        case "Week":
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case "Month":
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case "Quarter":
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case "Year":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        default: // "All Time"
            startDate = Date.distantPast
        }
        
        return date >= startDate
    }
}
