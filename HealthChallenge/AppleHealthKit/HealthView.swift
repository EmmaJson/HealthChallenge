//
//  HealthView.swift
//  HealthChallenge
//
//  Created by Emma Johansson on 2024-12-30.
//

import SwiftUI
import Charts

import SwiftUI
import Charts

struct HealthView: View {
    @StateObject private var viewModel = HealthKitViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Charts")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack {
                    if viewModel.isLoading {
                        VStack {
                            ShimmerView()
                                .frame(width: 300, height: 30)
                                .cornerRadius(10)
                                .padding(.bottom, 10)

                            ShimmerView()
                                .frame(width: 300, height: 30)
                                .cornerRadius(10)
                                .padding(.bottom, 20)

                            ShimmerView()
                                .frame(height: 300)
                                .cornerRadius(10)
                                .padding(.bottom, 20)

                            HStack {
                                Spacer()
                                VStack(spacing: 16) {
                                    ShimmerView()
                                        .frame(width: 110, height: 20)
                                    ShimmerView()
                                        .frame(width: 80, height: 30)
                                }
                                .frame(width: 110, height: 80)
                                .padding()
                                Spacer()
                                VStack(spacing: 16) {
                                    ShimmerView()
                                        .frame(width: 110, height: 20)
                                    ShimmerView()
                                        .frame(width: 80, height: 30)
                                }
                                .frame(width: 110, height: 80)
                                .padding()
                                Spacer()
                            }
                        }
                        .padding()
                    } else {
                        VStack {
                            Picker("Metric", selection: $viewModel.selectedMetric) {
                                ForEach(MetricType.allCases, id: \.self) { metric in
                                    Text(metric.rawValue).tag(metric)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            
                            Picker("Time Period", selection: $viewModel.selectedTimePeriod) {
                                ForEach(TimePeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            
                            VStack {
                                if viewModel.data.isEmpty {
                                    Text("No data available.")
                                        .foregroundColor(.red)
                                } else {
                                    Chart {
                                        ForEach(Array(zip(viewModel.labels, viewModel.data)), id: \.0) { label, value in
                                            BarMark(
                                                x: .value("Time", label),
                                                y: .value(viewModel.selectedMetric.rawValue, value)
                                            )
                                        }
                                    }
                                    .frame(height: 300)
                                    .padding()
                                }
                            }
                            
                            HStack {
                                Spacer()
                                VStack(spacing: 16) {
                                    Text("Average")
                                        .font(.title2)
                                    Text("\(viewModel.average, specifier: "%.0f")")
                                        .font(.title3)
                                }
                                .frame(width: 110)
                                .padding()
                                .background(.accent.opacity(0.1))
                                .cornerRadius(10)
                                Spacer()
                                VStack(spacing: 16) {
                                    Text("Total")
                                        .font(.title2)
                                    Text("\(viewModel.total, specifier: "%.0f")")
                                        .font(.title3)
                                }
                                .frame(width: 110)
                                .padding()
                                .background(.accent.opacity(0.1))
                                .cornerRadius(10)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .refreshable {
            viewModel.fetchData()
        }
    }
}
