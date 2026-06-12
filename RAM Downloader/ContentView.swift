//
//  ContentView.swift
//  RAM Downloader
//
//  Created by dylan on 6/10/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = RAMDownloadViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ramCard
                    tierPicker

                    if vm.isDownloading || vm.didSucceed {
                        statusCard
                        statsRow
                        logCard
                    }

                    totalCard
                    downloadButton
                }
                .padding()
            }
            .navigationTitle("Download More RAM")
        }
    }
    
    private var ramCard: some View {
        VStack(spacing: 8) {
            Text(vm.currentRAMLabel)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("Current RAM • \(vm.selectedTier.ramType)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var tierPicker: some View {
        Picker("Amount", selection: $vm.selectedTier) {
            ForEach(RAMTier.allCases) { tier in
                Text(tier.rawValue).tag(tier)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .disabled(vm.isDownloading)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(vm.phaseLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(vm.progress * 100))%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            ProgressView(value: vm.progress)
                .tint(.accentColor)

            if vm.didSucceed {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("RAM successfully installed!")
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(label: "Speed", value: vm.downloadSpeed, icon: "speedometer")
            statTile(label: "Latency", value: vm.latency, icon: "bolt.fill")
        }
    }

    private func statTile(label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title3.monospacedDigit())
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Log")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(vm.logLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 100)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var totalCard: some View {
        HStack {
            Text("Total Downloaded")
            Spacer()
            Text(vm.totalDownloadedLabel)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var downloadButton: some View {
        Button(action: {
            vm.startDownload()
        }) {
            Text(vm.isDownloading ? "Downloading…" : "Download More RAM")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isDownloading ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .disabled(vm.isDownloading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
