//
//  StaffAnalyticsView.swift
//  TheBookDiaries
//
//  Created by Stephanie Shen on 6/20/25.
//

import SwiftUI
import Charts

struct StaffAnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var readingTracker = ReadingTrackerService.shared
    @ObservedObject var viewModel: CollectionViewModel
    
    @State private var selectedTimeRange: TimeRange = .thisMonth
    @State private var showingExportSheet = false
    @State private var csvFileURL: URL?
    
    enum TimeRange: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case thisYear = "This Year"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time range selector
                    TimeRangeSelector()
                    
                    // Key metrics cards
                    KeyMetricsSection()
                    
                    // Reading activity chart
                    ReadingActivityChart()
                    
                    // Popular books section
                    PopularBooksSection()
                    
                    // Collections analytics
                    CollectionsAnalyticsSection()
                    
                    // Reader engagement
                    ReaderEngagementSection()
                }
                .padding()
            }
            .navigationTitle("Analytics Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        exportAnalytics()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = csvFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    // MARK: - Time Range Selector
    @ViewBuilder
    private func TimeRangeSelector() -> some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Key Metrics Section
    @ViewBuilder
    private func KeyMetricsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                MetricCard(
                    title: "Total Books",
                    value: "\(getTotalBooksCount())",
                    change: "+12",
                    changeType: .positive,
                    icon: "books.vertical.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Active Readers",
                    value: "\(getActiveReadersCount())",
                    change: "+5",
                    changeType: .positive,
                    icon: "person.2.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Books Read",
                    value: "\(readingTracker.readingLogs.count)",
                    change: "+8",
                    changeType: .positive,
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
                
                MetricCard(
                    title: "Collections",
                    value: "\(viewModel.collections.count)",
                    change: "+2",
                    changeType: .positive,
                    icon: "folder.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Reading Activity Chart
    @ViewBuilder
    private func ReadingActivityChart() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reading Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(selectedTimeRange.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Simple chart representation (would use Swift Charts in real implementation)
            VStack(spacing: 8) {
                ForEach(getChartData(), id: \.date) { dataPoint in
                    HStack {
                        Text(dataPoint.label)
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * dataPoint.percentage)
                                
                                Spacer()
                            }
                        }
                        .frame(height: 20)
                        
                        Text("\(dataPoint.value)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Popular Books Section
    @ViewBuilder
    private func PopularBooksSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Read Books")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(getMostReadBooks(), id: \.title) { bookData in
                    HStack(spacing: 12) {
                        // Rank badge
                        Text("\(bookData.rank)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(rankColor(bookData.rank))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bookData.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text("by \(bookData.author)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(bookData.readCount)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text("reads")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Collections Analytics
    @ViewBuilder
    private func CollectionsAnalyticsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Collections Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.collections.isEmpty {
                Text("No collections created yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.collections.prefix(5)) { collection in
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            
                            Text(collection.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(collection.books.count) books")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if viewModel.collections.count > 5 {
                        Text("+ \(viewModel.collections.count - 5) more collections")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Reader Engagement Section
    @ViewBuilder
    private func ReaderEngagementSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reader Engagement")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                EngagementMetric(
                    title: "Average Books per Reader",
                    value: String(format: "%.1f", getAverageBooksPerReader()),
                    icon: "person.crop.circle.fill",
                    color: .blue
                )
                
                EngagementMetric(
                    title: "Most Active Reader",
                    value: getMostActiveReaderName(),
                    icon: "star.fill",
                    color: .yellow
                )
                
                EngagementMetric(
                    title: "Reading Goal Completion",
                    value: "\(getGoalCompletionRate())%",
                    icon: "target",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func getTotalBooksCount() -> Int {
        // This would come from your actual database
        return 150
    }
    
    private func getActiveReadersCount() -> Int {
        // Count unique readers from reading logs
        return max(1, readingTracker.readingLogs.count / 3) // Simplified calculation
    }
    
    private func getChartData() -> [ChartDataPoint] {
        // Mock data - in real app, this would be calculated from actual reading logs
        switch selectedTimeRange {
        case .thisWeek:
            return [
                ChartDataPoint(date: Date(), label: "Mon", value: 5, percentage: 0.5),
                ChartDataPoint(date: Date(), label: "Tue", value: 8, percentage: 0.8),
                ChartDataPoint(date: Date(), label: "Wed", value: 3, percentage: 0.3),
                ChartDataPoint(date: Date(), label: "Thu", value: 10, percentage: 1.0),
                ChartDataPoint(date: Date(), label: "Fri", value: 7, percentage: 0.7),
                ChartDataPoint(date: Date(), label: "Sat", value: 12, percentage: 1.2),
                ChartDataPoint(date: Date(), label: "Sun", value: 6, percentage: 0.6)
            ]
        case .thisMonth:
            return [
                ChartDataPoint(date: Date(), label: "Week 1", value: 25, percentage: 0.6),
                ChartDataPoint(date: Date(), label: "Week 2", value: 32, percentage: 0.8),
                ChartDataPoint(date: Date(), label: "Week 3", value: 40, percentage: 1.0),
                ChartDataPoint(date: Date(), label: "Week 4", value: 28, percentage: 0.7)
            ]
        default:
            return []
        }
    }
    
    private func getMostReadBooks() -> [PopularBookData] {
        // Mock data - in real app, aggregate from reading logs
        return [
            PopularBookData(rank: 1, title: "The Midnight Library", author: "Matt Haig", readCount: 15),
            PopularBookData(rank: 2, title: "Atomic Habits", author: "James Clear", readCount: 12),
            PopularBookData(rank: 3, title: "The Seven Husbands of Evelyn Hugo", author: "Taylor Jenkins Reid", readCount: 10),
            PopularBookData(rank: 4, title: "Educated", author: "Tara Westover", readCount: 8),
            PopularBookData(rank: 5, title: "Where the Crawdads Sing", author: "Delia Owens", readCount: 7)
        ]
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
    
    private func getAverageBooksPerReader() -> Double {
        guard getActiveReadersCount() > 0 else { return 0.0 }
        return Double(readingTracker.readingLogs.count) / Double(getActiveReadersCount())
    }
    
    private func getMostActiveReaderName() -> String {
        // This would be calculated from actual user data
        return "BookLover123"
    }
    
    private func getGoalCompletionRate() -> Int {
        // Calculate percentage of users who met their reading goals
        return 73 // Mock data
    }
    
    private func exportAnalytics() {
        // Generate analytics report
        var csvContent = "Metric,Value,Period\n"
        csvContent += "Total Books,\(getTotalBooksCount()),\(selectedTimeRange.rawValue)\n"
        csvContent += "Active Readers,\(getActiveReadersCount()),\(selectedTimeRange.rawValue)\n"
        csvContent += "Books Read,\(readingTracker.readingLogs.count),\(selectedTimeRange.rawValue)\n"
        csvContent += "Collections,\(viewModel.collections.count),\(selectedTimeRange.rawValue)\n"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("analytics_report.csv")
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            csvFileURL = tempURL
            showingExportSheet = true
        } catch {
            print("Error exporting analytics: \(error)")
        }
    }
}

// MARK: - Supporting Views and Models

struct MetricCard: View {
    let title: String
    let value: String
    let change: String
    let changeType: ChangeType
    let icon: String
    let color: Color
    
    enum ChangeType {
        case positive, negative, neutral
        
        var color: Color {
            switch self {
            case .positive: return .green
            case .negative: return .red
            case .neutral: return .gray
            }
        }
        
        var symbol: String {
            switch self {
            case .positive: return "+"
            case .negative: return "-"
            case .neutral: return ""
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(changeType.symbol + change)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(changeType.color)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ChartDataPoint {
    let date: Date
    let label: String
    let value: Int
    let percentage: Double
}

struct PopularBookData {
    let rank: Int
    let title: String
    let author: String
    let readCount: Int
}

struct EngagementMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct BulkImportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Bulk Import")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Import multiple books at once")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    Button("Import from CSV") {
                        // Handle CSV import
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Import from Goodreads") {
                        // Handle Goodreads import
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    
                    Button("Import from Library System") {
                        // Handle library system import
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bulk Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}