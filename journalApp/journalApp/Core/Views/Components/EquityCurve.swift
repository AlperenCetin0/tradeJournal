//
//  EquityCurve.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI
import Charts

struct EquityCurveView: View {
    // MARK: - Properties
    let trades: [Trade]
    @State private var selectedTrade: Trade?
    @State private var selectedDate: Date?
    
    private var cumulativeProfitLoss: [(date: Date, total: Double)] {
        guard !trades.isEmpty else { return [] }
        
        var runningTotal = 0.0
        var points: [(date: Date, total: Double)] = []
        let sortedTrades = trades.sorted { $0.date < $1.date }
        
        // Add points for each trade
        for trade in sortedTrades {
            runningTotal += trade.profitLoss
            points.append((trade.date, runningTotal))
        }
        
        return points
    }
    
    private var yAxisRange: ClosedRange<Double> {
        let values = cumulativeProfitLoss.map { $0.total }
        let minValue = min(0, values.min() ?? 0)
        let maxValue = max(0, values.max() ?? 0)
        let padding = max(abs(maxValue), abs(minValue)) * 0.1
        return (minValue - padding)...(maxValue + padding)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Equity Curve")
                .font(.headline)
            
            if trades.isEmpty {
                Text("No trades available")
                    .foregroundColor(.secondary)
                    .frame(height: 300)
            } else {
                chartView
            }
            
            if let selectedTrade = selectedTrade {
                tradeDetailsCard(for: selectedTrade)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    // MARK: - Supporting Views
    private var chartView: some View {
        Chart {
            ForEach(cumulativeProfitLoss, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Equity", point.total)
                )
                .foregroundStyle(.green)
                .interpolationMethod(.linear)
                
                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Baseline", 0),
                    yEnd: .value("Equity", point.total)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.green.opacity(0.2), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                if let selectedDate = selectedDate,
                   abs(selectedDate.timeIntervalSince(point.date)) < 12 * 60 * 60 {
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Equity", point.total)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(100)
                } else {
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Equity", point.total)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(30)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .currency(code: "USD").presentation(.narrow))
            }
        }
        .chartYScale(domain: yAxisRange)
        .frame(height: 300)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                guard let date = proxy.value(atX: x, as: Date.self) else { return }
                                selectedDate = date
                                
                                // Find the closest trade to the selected date
                                var closestTrade: Trade? = nil
                                var closestDistance: TimeInterval = .infinity
                                
                                for trade in trades {
                                    let distance = abs(trade.date.timeIntervalSince(date))
                                    if distance < closestDistance {
                                        closestDistance = distance
                                        closestTrade = trade
                                    }
                                }
                                
                                // Only update if within 12 hours
                                if closestDistance < 12 * 60 * 60 {
                                    selectedTrade = closestTrade
                                } else {
                                    selectedTrade = nil
                                }
                            }
                            .onEnded { _ in
                                selectedDate = nil
                                selectedTrade = nil
                            }
                    )
            }
        }
    }
    
    private func tradeDetailsCard(for trade: Trade) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Trade Details")
                .font(.headline)
            
            Group {
                Text("Date: \(trade.date.formatted())")
                Text("P/L: \(String(format: "$%.2f", trade.profitLoss))")
                    .foregroundColor(trade.profitLoss >= 0 ? .green : .red)
                Text("Strategy: \(trade.strategy)")
                Text("Time Frame: \(trade.timeFrame.rawValue)")
                Text("R:R: \(String(format: "%.2f", trade.riskRewardRatio))")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
