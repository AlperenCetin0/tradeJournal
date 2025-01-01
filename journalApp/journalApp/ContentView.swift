//
//  ContentView.swift
//  journalApp
//
//  Created by Alperen Çetin on 1.01.2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = TradeListViewModel()
    @State private var showingAddTrade = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedTab = 0
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            // Journal Tab
            NavigationView {
                VStack(spacing: 0) {
                    // Stats card section
                    StatsCardView(
                        totalPL: calculateTotalPL(),
                        winRate: calculateWinRate(),
                        profitFactor: calculateProfitFactor(),
                        avgRR: calculateAverageRR()
                    )
                    .frame(height: 180)
                    .padding(.horizontal)
                    .background(Color(.systemGroupedBackground))
                    
                    // List section
                    List {
                        ForEach(viewModel.trades) { trade in
                            TradeRowView(trade: trade)
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(currentItem: trade)
                                }
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationTitle("Trade Journal")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isDarkMode.toggle()
                            setAppTheme(isDarkMode)
                        }) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddTrade = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: $showingAddTrade) {
                    NavigationView {
                        AddTradeView(tradeListViewModel: viewModel)
                    }
                }
            }
            .tabItem {
                Label("Journal", systemImage: "list.bullet")
            }
            .tag(0)
            
            // Analysis Tab
            TradeAnalysisView(viewModel: viewModel)
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar")
                }
                .tag(1)
        }
        .onAppear { setAppTheme(isDarkMode) }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // MARK: - Stats Calculation Methods
    private func calculateTotalPL() -> Double {
        viewModel.trades.reduce(0) { $0 + $1.profitLoss }
    }
    
    private func calculateWinRate() -> Double {
        let winningTrades = viewModel.trades.filter { $0.profitLoss > 0 }.count
        return viewModel.trades.isEmpty ? 0 : Double(winningTrades) / Double(viewModel.trades.count) * 100
    }
    
    private func calculateProfitFactor() -> Double {
        let profits = viewModel.trades.filter { $0.profitLoss > 0 }.reduce(0.0) { $0 + $1.profitLoss }
        let losses = abs(viewModel.trades.filter { $0.profitLoss < 0 }.reduce(0.0) { $0 + $1.profitLoss })
        return losses == 0 ? 0 : profits / losses
    }
    
    private func calculateAverageRR() -> Double {
        viewModel.trades.isEmpty ? 0 : viewModel.trades.reduce(0) { $0 + $1.riskRewardRatio } / Double(viewModel.trades.count)
    }
    
    // MARK: - Helper Methods
    private func setAppTheme(_ isDark: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
}

#Preview {
    ContentView()
}
