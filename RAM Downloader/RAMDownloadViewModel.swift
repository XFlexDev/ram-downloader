//
//  RAMDownloadViewModel.swift
//  RAM Downloader
//
//  Created by dylan on 6/10/26.
//

import SwiftUI
import Combine

enum RAMTier: String, CaseIterable, Identifiable {
    case mb256 = "+256 MB"
    case gb1   = "+1 GB"
    case gb8   = "+8 GB"
    case tb1   = "+1 TB"

    var id: String { rawValue }

    var megabytes: Double {
        switch self {
        case .mb256: return 256
        case .gb1:   return 1024
        case .gb8:   return 8192
        case .tb1:   return 1_048_576
        }
    }

    var ramType: String {
        switch self {
        case .mb256: return "DDR4"
        case .gb1:   return "DDR5"
        case .gb8:   return "LPDDR5X"
        case .tb1:   return "GDDR7"
        }
    }
}

let downloadPhases: [String] = [
    "Connecting to RAM servers…",
    "Negotiating memory protocol…",
    "Allocating virtual heap…",
    "Routing through bit tubes…",
    "Compressing quantum bytes…",
    "Decompressing on arrival…",
    "Injecting into kernel…",
    "Patching RAM table…",
    "Flushing L3 cache…",
    "Writing to /dev/ram0…",
    "Verifying checksum…",
    "Finalizing allocation…"
]

let downloadLogLines: [String] = [
    "> pinging ram.downloadmoreram.com",
    "> negotiating TLS 1.4 handshake",
    "> allocating virtual heap",
    "> requesting 64-bit memory block",
    "> routing via IPv6 ram relay",
    "> defragmenting bit buffer",
    "> injecting memory into kernel",
    "> patching dynamic ram table",
    "> flushing l3 cache residuals",
    "> writing to /dev/ram0",
    "> verifying checksum: 0xDEADBEEF",
    "> memory seated successfully ✓"
]

class RAMDownloadViewModel: ObservableObject {

    @Published var selectedTier: RAMTier = .mb256
    @Published var isDownloading: Bool = false
    @Published var progress: Double = 0
    @Published var phaseLabel: String = "Ready to download"
    @Published var downloadSpeed: String = "—"
    @Published var latency: String = "—"
    @Published var logLines: [String] = ["$ awaiting user input…"]
    @Published var totalDownloadedMB: Double = 0
    @Published var didSucceed: Bool = false

    private var timer: AnyCancellable?
    private var phaseIndex: Int = 0
    private var logIndex: Int = 0

    var currentRAMLabel: String {
        formatBytes(256 + totalDownloadedMB)
    }

    var totalDownloadedLabel: String {
        formatBytes(totalDownloadedMB)
    }

    func startDownload() {
        guard !isDownloading else { return }
        isDownloading = true
        didSucceed = false
        progress = 0
        phaseIndex = 0
        logIndex = 0
        latency = String(format: "%.1f ms", Double.random(in: 0.4...8.9))
        addLog("$ initiating download: \(selectedTier.rawValue)")

        let tickInterval = 0.06
        let totalDuration = 4.5
        let increment = tickInterval / totalDuration

        timer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tick(increment: increment)
            }
    }

    private func tick(increment: Double) {
        let jitter = Double.random(in: 0...increment * 0.4)
        progress = min(1.0, progress + increment + jitter)

        let speedMBs = (selectedTier.megabytes / 4.5) * Double.random(in: 0.8...1.2)
        if speedMBs >= 1024 {
            downloadSpeed = String(format: "%.1f GB/s", speedMBs / 1024)
        } else {
            downloadSpeed = String(format: "%.0f MB/s", speedMBs)
        }

        let newPhaseIndex = min(downloadPhases.count - 1, Int(progress * Double(downloadPhases.count)))
        if newPhaseIndex != phaseIndex {
            phaseIndex = newPhaseIndex
            phaseLabel = downloadPhases[phaseIndex]
        }

        if Double.random(in: 0...1) < 0.12 && logIndex < downloadLogLines.count {
            addLog(downloadLogLines[logIndex])
            logIndex += 1
        }

        if progress >= 1.0 {
            finish()
        }
    }

    private func finish() {
        timer?.cancel()
        timer = nil
        totalDownloadedMB += selectedTier.megabytes
        progress = 1.0
        phaseLabel = "Complete!"
        downloadSpeed = "—"
        didSucceed = true
        isDownloading = false
        addLog("> RAM installation complete ✓")
    }

    private func addLog(_ line: String) {
        logLines.append(line)
        if logLines.count > 30 {
            logLines.removeFirst()
        }
    }

    func formatBytes(_ mb: Double) -> String {
        if mb >= 1_048_576 { return String(format: "%.2f TB", mb / 1_048_576) }
        if mb >= 1024      { return String(format: "%.1f GB", mb / 1024) }
        return String(format: "%.0f MB", mb)
    }
}
