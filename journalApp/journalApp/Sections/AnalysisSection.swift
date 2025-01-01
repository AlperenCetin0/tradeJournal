//
//  AnalysisSection.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI
import Charts

struct AnalysisSection: View {
    // MARK: - Properties
    @State private var selectedTimeFrame: TimeFrame = .weekly
    @StateObject private var viewModel = TradeListViewModel() // Add TradeListViewModel
    
    // MARK: - Enums
    enum TimeFrame: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Analysis Period")) {
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical)
                }
                
                Section {
                    NavigationLink(destination: PerformanceView(trades: viewModel.trades)) { // Pass viewModel.trades
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Performance Analysis")
                        }
                    }
                    
                    NavigationLink(destination: PatternsView()) {
                        HStack {
                            Image(systemName: "rectangle.3.group")
                            Text("Trading Patterns")
                        }
                    }
                    
                    NavigationLink(destination: RiskView()) {
                        HStack {
                            Image(systemName: "exclamationmark.shield")
                            Text("Risk Analysis")
                        }
                    }
                    
                    NavigationLink(destination: PsychologyView()) {
                        HStack {
                            Image(systemName: "brain")
                            Text("Trading Psychology")
                        }
                    }
                    
                    NavigationLink(destination: SymbolAnalysisView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                            Text("Symbol Analysis")
                        }
                    }
                }
            }
            .navigationTitle("Analysis")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct PerformanceView: View {
    let trades: [Trade]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Performance Over Time")
                        .font(.headline)
                    
                    if !trades.isEmpty {
                        Chart(trades, id: \.id) { trade in
                            LineMark(
                                x: .value("Date", trade.date),
                                y: .value("Profit/Loss", trade.profitLoss)
                            )
                            .foregroundStyle(trade.profitLoss >= 0 ? Color.green : Color.red)
                        }
                        .frame(height: 300)
                    } else {
                        Text("No trade data available")
                            .foregroundColor(.secondary)
                            .frame(height: 300)
                    }
                }
                .padding()
                
                // Statistics Grid using TradeListViewModel methods
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    let viewModel = TradeListViewModel() // Create viewModel for calculations
                    
                    StatCard(title: "Win Rate",
                           value: String(format: "%.1f%%", viewModel.winRate),
                           icon: "percent")
                    
                    StatCard(title: "Profit Factor",
                           value: String(format: "%.2f", viewModel.profitFactor),
                           icon: "chart.bar")
                    
                    StatCard(title: "Total P/L",
                           value: "$\(Int(viewModel.totalProfitLoss))",
                           icon: "dollarsign.circle")
                    
                    StatCard(title: "Avg R:R",
                           value: String(format: "%.1f", viewModel.averageRiskRewardRatio),
                           icon: "arrow.left.and.right")
                }
                .padding()
                
                // Monthly Performance
                VStack(alignment: .leading) {
                    Text("Monthly Performance")
                        .font(.headline)
                    
                    if !trades.isEmpty {
                        Chart(groupTradesByMonth(), id: \.month) { monthData in
                            BarMark(
                                x: .value("Month", monthData.month),
                                y: .value("Total", monthData.total)
                            )
                            .foregroundStyle(monthData.total >= 0 ? Color.green : Color.red)
                        }
                        .frame(height: 200)
                    } else {
                        Text("No monthly data available")
                            .foregroundColor(.secondary)
                            .frame(height: 200)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Performance")
    }
    
    private struct MonthlyData: Identifiable {
        let id = UUID()
        let month: String
        let total: Double
    }
    
    private func groupTradesByMonth() -> [MonthlyData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        let groupedTrades = Dictionary(grouping: trades) { trade in
            dateFormatter.string(from: trade.date)
        }
        
        return groupedTrades.map { month, trades in
            MonthlyData(
                month: month,
                total: trades.reduce(into: 0.0) { result, trade in
                    result += trade.profitLoss
                }
            )
        }.sorted { $0.month < $1.month }
    }
}

struct PatternsView: View {
    @StateObject private var viewModel = TradeListViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Pattern Success Rates")
                        .font(.headline)
                    
                    if !viewModel.trades.isEmpty {
                        Chart(getPatternStats(), id: \.pattern) { data in
                            BarMark(
                                x: .value("Success Rate", data.successRate),
                                y: .value("Pattern", data.pattern)
                            )
                            .foregroundStyle(Color.blue)
                        }
                        .frame(height: 300)
                    } else {
                        Text("No pattern data available")
                            .foregroundColor(.secondary)
                            .frame(height: 300)
                    }
                }
                .padding()
                
                ForEach(getPatternStats(), id: \.pattern) { patternData in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(patternData.pattern)
                            .font(.headline)
                        
                        HStack {
                            Text("Success Rate: \(String(format: "%.1f%%", patternData.successRate))")
                            Spacer()
                            Text("Total Trades: \(patternData.totalTrades)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Current Streak:")
                                Text("\(patternData.currentWinStreak) wins")
                                    .foregroundColor(.green)
                                Spacer()
                                Text("Best Streak:")
                                Text("\(patternData.maxWinStreak) wins")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("Avg Profit:")
                                Text("$\(String(format: "%.2f", patternData.averageProfit))")
                                    .foregroundColor(patternData.averageProfit >= 0 ? .green : .red)
                                Spacer()
                                Text("Total P/L:")
                                Text("$\(String(format: "%.2f", patternData.totalProfitLoss))")
                                    .foregroundColor(patternData.totalProfitLoss >= 0 ? .green : .red)
                            }
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Patterns")
    }
    
    // MARK: - Pattern Statistics
    private struct PatternStatistics: Identifiable {
        let id = UUID()
        let pattern: String
        let successRate: Double
        let totalTrades: Int
        let currentWinStreak: Int
        let maxWinStreak: Int
        let averageProfit: Double
        let totalProfitLoss: Double
    }
    
    private func getPatternStats() -> [PatternStatistics] {
        let groupedTrades = Dictionary(grouping: viewModel.trades) { $0.strategy }
        
        return groupedTrades.map { pattern, trades in
            let successfulTrades = trades.filter { $0.profitLoss > 0 }
            let successRate = Double(successfulTrades.count) / Double(trades.count) * 100
            let avgProfit = trades.reduce(0.0) { $0 + $1.profitLoss } / Double(trades.count)
            let totalPL = trades.reduce(0.0) { $0 + $1.profitLoss }
            let currentStreak = calculateCurrentWinStreak(trades: trades)
            let maxStreak = calculateMaxWinStreak(trades: trades)
            
            return PatternStatistics(
                pattern: pattern,
                successRate: successRate,
                totalTrades: trades.count,
                currentWinStreak: currentStreak,
                maxWinStreak: maxStreak,
                averageProfit: avgProfit,
                totalProfitLoss: totalPL
            )
        }.sorted { $0.successRate > $1.successRate }
    }
    
    private func calculateMaxWinStreak(trades: [Trade]) -> Int {
        var currentStreak = 0
        var maxStreak = 0
        
        for trade in trades.sorted(by: { $0.date < $1.date }) {
            if trade.profitLoss > 0 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
    
    private func calculateCurrentWinStreak(trades: [Trade]) -> Int {
        var streak = 0
        let sortedTrades = trades.sorted(by: { $0.date > $1.date }) // Sort by most recent
        
        for trade in sortedTrades {
            if trade.profitLoss > 0 {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
}

struct RiskView: View {
    // Add TradeListViewModel to access trades
    @StateObject private var viewModel = TradeListViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Risk Metrics Overview Chart
                VStack(alignment: .leading) {
                    Text("Risk Metrics Overview")
                        .font(.headline)
                    
                    if !viewModel.trades.isEmpty {
                        Chart(viewModel.trades, id: \.id) { trade in
                            LineMark(
                                x: .value("Date", trade.date),
                                y: .value("Risk Amount", trade.riskAmount)
                            )
                            .foregroundStyle(Color.red)
                        }
                        .frame(height: 300)
                    } else {
                        Text("No risk data available")
                            .foregroundColor(.secondary)
                            .frame(height: 300)
                    }
                }
                .padding()
                
                // Risk Metrics Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    let averageRiskReward = calculateAverageRR(trades: viewModel.trades)
                    let maxDrawdown = calculateMaxDrawdown(trades: viewModel.trades)
                    let averageRiskPerTrade = calculateAverageRisk(trades: viewModel.trades)
                    let profitableRiskTrades = calculateProfitableRiskTrades(trades: viewModel.trades)
                    
                    StatCard(title: "Avg R:R Ratio",
                           value: String(format: "1:%.1f", averageRiskReward),
                           icon: "arrow.left.and.right")
                    
                    StatCard(title: "Max Drawdown",
                           value: String(format: "%.1f%%", maxDrawdown),
                           icon: "arrow.down.right")
                    
                    StatCard(title: "Avg Risk/Trade",
                           value: String(format: "$%.0f", averageRiskPerTrade),
                           icon: "percent")
                    
                    StatCard(title: "Profitable Risk Trades",
                           value: String(format: "%.1f%%", profitableRiskTrades),
                           icon: "checkmark.circle")
                }
                .padding()
                
                // Risk Distribution Chart
                VStack(alignment: .leading) {
                    Text("Risk Distribution")
                        .font(.headline)
                    
                    if !viewModel.trades.isEmpty {
                        Chart(Array(getRiskDistribution(trades: viewModel.trades)), id: \.risk) { data in
                            BarMark(
                                x: .value("Risk Amount", data.risk),
                                y: .value("Count", data.count)
                            )
                            .foregroundStyle(Color.blue)
                        }
                        .frame(height: 200)
                    } else {
                        Text("No risk distribution data available")
                            .foregroundColor(.secondary)
                            .frame(height: 200)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Risk Analysis")
    }
    
    // MARK: - Risk Calculation Methods
    private func calculateAverageRR(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0 }
        return trades.reduce(0) { $0 + $1.riskRewardRatio } / Double(trades.count)
    }
    
    private func calculateMaxDrawdown(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0 }
        var maxDrawdown = 0.0
        var peak = 0.0
        var runningPL = 0.0
        
        for trade in trades {
            runningPL += trade.profitLoss
            peak = max(peak, runningPL)
            let drawdown = (peak - runningPL) / peak * 100
            maxDrawdown = max(maxDrawdown, drawdown)
        }
        
        return maxDrawdown
    }
    
    private func calculateAverageRisk(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0 }
        return trades.reduce(0) { $0 + $1.riskAmount } / Double(trades.count)
    }
    
    private func calculateProfitableRiskTrades(trades: [Trade]) -> Double {
        guard !trades.isEmpty else { return 0 }
        let profitableTrades = trades.filter { $0.profitLoss > 0 }.count
        return Double(profitableTrades) / Double(trades.count) * 100
    }
    
    // MARK: - Risk Distribution Helper
    private struct RiskDistributionData {
        let risk: Double
        let count: Int
    }
    
    private func getRiskDistribution(trades: [Trade]) -> [RiskDistributionData] {
        let riskRanges = Dictionary(grouping: trades) { trade -> Double in
            // Round to nearest 100
            return round(trade.riskAmount / 100) * 100
        }
        
        return riskRanges.map { RiskDistributionData(risk: $0.key, count: $0.value.count) }
            .sorted { $0.risk < $1.risk }
    }
}

struct PsychologyView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Emotional State Over Time")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(Text("Emotional State Chart"))
                }
                .padding()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    StatCard(title: "Stress Level", value: "Low", icon: "heart.fill")
                    StatCard(title: "Focus Score", value: "8/10", icon: "brain.head.profile")
                    StatCard(title: "Confidence", value: "High", icon: "star.fill")
                    StatCard(title: "Discipline", value: "9/10", icon: "checkmark.shield")
                }
                .padding()
                
                VStack(alignment: .leading) {
                    Text("Recent Trading Notes")
                        .font(.headline)
                    
                    ForEach(["Maintained discipline during volatility", "Followed trading plan consistently", "Avoided FOMO trades"], id: \.self) { note in
                        HStack {
                            Image(systemName: "note.text")
                            Text(note)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Trading Psychology")
    }
}

struct SymbolAnalysisView: View {
    @ObservedObject var viewModel: TradeListViewModel
    @State private var selectedSymbol: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Showing top 10 most traded symbols")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Symbol Distribution")
                        .font(.headline)
                    
                    if !viewModel.filteredTrades.isEmpty {
                        let symbolData = viewModel.groupTradesBySymbol()
                        
                        Chart(symbolData, id: \.symbol) { data in
                            SectorMark(
                                angle: .value("Count", data.stats.totalTrades),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("Symbol", data.symbol))
                            .cornerRadius(4)
                        }
                        .frame(height: 300)
                        .chartLegend(position: .bottom, spacing: 20)
                        .padding()
                        
                        // Use LazyVGrid for better performance with many items
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(symbolData, id: \.symbol) { data in
                                Button(action: {
                                    selectedSymbol = data.symbol
                                }) {
                                    Text(data.symbol)
                                        .padding(8)
                                        .background(selectedSymbol == data.symbol ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedSymbol == data.symbol ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    } else {
                        Text("No symbol data available")
                            .foregroundColor(.secondary)
                            .frame(height: 300)
                    }
                }
                
                // Selected Symbol Statistics
                if let symbol = selectedSymbol,
                   let stats = viewModel.getSymbolStats(for: symbol) {
                    VStack(spacing: 15) {
                        Text(symbol)
                            .font(.title2)
                            .bold()
                        
                        HStack(spacing: 30) {
                            StatBox(title: "Total Trades",
                                   value: "\(stats.totalTrades)",
                                   color: .blue)
                            
                            StatBox(title: "Win Rate",
                                   value: String(format: "%.1f%%", stats.winRate),
                                   color: stats.winRate >= 50 ? .green : .red)
                        }
                        
                        HStack(spacing: 30) {
                            StatBox(title: "Avg Profit",
                                   value: String(format: "$%.2f", stats.avgProfit),
                                   color: stats.avgProfit >= 0 ? .green : .red)
                            
                            StatBox(title: "Total P/L",
                                   value: String(format: "$%.2f", stats.totalPL),
                                   color: stats.totalPL >= 0 ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Symbol Analysis")
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
            
            Text(value)
                .font(.title)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PatternCard: View {
    let pattern: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(pattern)
                .font(.headline)
            
            HStack {
                Text("Success Rate: 75%")
                Spacer()
                Text("Total Trades: 45")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(Text("Pattern Example"))
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct AnalysisSection_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisSection()
    }
}
