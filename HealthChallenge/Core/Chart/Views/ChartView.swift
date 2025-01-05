//
//  HealthView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import SwiftUI
import Charts

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Charts")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("Metric", selection: $viewModel.selectedMetric) {
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(5)
                
                Picker("Time Period", selection: $viewModel.selectedTimePeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(5)
                
                Chart {
                    ForEach(Array(zip(viewModel.labels, viewModel.data)), id: \.0) { label, value in
                        BarMark(
                            x: .value("Time", transformLabel(label: label)),
                            y: .value(viewModel.selectedMetric.rawValue, value)
                        )
                    }
                }
                .padding()
                
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if(viewModel.selectedTimePeriod == .week || viewModel.selectedTimePeriod == .year) {
                                Text(value.as(String.self) ?? "")
                                    .padding(.top)
                                    .font(.footnote)
                                    .bold()
                                    .minimumScaleFactor(0.5)
                                    .frame(maxHeight: 0.5, alignment: .center)
                            } else {
                                Text(value.as(String.self) ?? "")
                                    .padding(.top)
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .rotationEffect(.degrees(90)) // Rotate text if needed
                                    .frame(maxHeight: 0.5, alignment: .center)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            Text("\(value.as(Double.self) ?? 0, specifier: "%.0f")")
                                .font(.caption)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                
                HStack {
                    Spacer()
                    StatisticCardView(title: "Average", value: viewModel.average)
                    Spacer()
                    StatisticCardView(title: "Total", value: viewModel.total)
                    Spacer()
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.fetchData()
        }
    }
    
    private func transformLabel(label: String) -> String {
        switch viewModel.selectedTimePeriod {
        case .day:
            if label.count > 4 {
                return String(label.prefix(2))
            } else {
                return String(label.prefix(1))
            }
        case .week:
            return label
        case .month:
            return String(label.prefix(2))
        case .year:
            return String(label.prefix(3))
        }
    }
}

struct StatisticCardView: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2)
            Text("\(value, specifier: "%.0f")")
                .font(.title3)
        }
        .frame(width: 110)
        .padding()
        .background(.accent.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ChartView()
}
