//
//  ContentView.swift
//  Advent of Code 2023 - Day 25
//
//  Created by Stephen H. Gerstacker on 2023-12-30.
//  SPDX-License-Identifier: MIT
//

import SwiftUI

extension String: Identifiable {
    public var id: String { self }
}

extension Int: Identifiable {
    public var id: Int { self }
}

enum CalculationError: Error {
    case failed
    
    var localizedDescription: String {
        switch self {
        case .failed:
            "Failed to perform the calculation"
        }
    }
}

struct ContentView: View {
    @State var isProcessing: Bool = true
    @State var pdfData: Data? = nil
    @State var lastErrorMessage: String? = nil
    @State var answer: Int? = nil
    
    @State var lhs1: String = ""
    @State var rhs1: String = ""
    @State var lhs2: String = ""
    @State var rhs2: String = ""
    @State var lhs3: String = ""
    @State var rhs3: String = ""
    
    var body: some View {
        VStack {
            PDFViewer(data: pdfData)
                .background(.white)
                .frame(minWidth: 300, minHeight: 300)
                .frame(maxHeight: .infinity)
                .alert(item: $lastErrorMessage) { message in
                    Alert(title: Text("Failed!"), message: Text(message))
                }
            
            HStack {
                TextField("LHS 1", text: $lhs1)
                TextField("RHS 1", text: $rhs1)
                
                TextField("LHS 2", text: $lhs2)
                TextField("RHS 2", text: $rhs2)
                
                TextField("LHS 3", text: $lhs3)
                TextField("RHS 3", text: $rhs3)
                
                Button(action: {
                    calculateAnswer()
                }, label: {
                    Text("Calculate!")
                })
                .disabled(calculateDisabled)
            }
        }
        .padding()
        .alert(item: $answer) { answer in
            Alert(title: Text("The Answer!"), message: Text("\(answer)"))
        }
        .disabled(isProcessing)
        .task {
            await generateAssets()
        }
    }
    
    private var calculateDisabled: Bool {
        lhs1.isEmpty || rhs1.isEmpty ||
        lhs2.isEmpty || rhs2.isEmpty ||
        lhs3.isEmpty || rhs3.isEmpty
    }
    
    private func calculateAnswer() {
        isProcessing = true
        lastErrorMessage = nil
        
        Task {
            do {
                let value = try await calculate()
                
                await MainActor.run {
                    answer = value
                }
            } catch {
                await MainActor.run {
                    lastErrorMessage = error.localizedDescription
                }
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    private func generateAssets() async {
        await MainActor.run {
            isProcessing = true
            lastErrorMessage = nil
        }
        
        do {
            let graphURL = try generateGraphFile()
            let clusteredURL = try await generateCluster(from: graphURL)
            let pdfURL = try await generateGraph(from: clusteredURL)
            
            try await MainActor.run {
                pdfData = try Data(contentsOf: pdfURL)
            }
        } catch {
            await MainActor.run {
                lastErrorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run { isProcessing = false }
    }
    
    private func generateCluster(from inputURL: URL) async throws -> URL {
        let processURL = URL(fileURLWithPath: "/opt/homebrew/Cellar/graphviz/9.0.0/bin/cluster")
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appending(path: "Day25Clustered.dot")
        
        let arguments = [
            "-C2",
            "-o",
            outputURL.path(percentEncoded: false),
            inputURL.path(percentEncoded: false),
        ]
        
        try await withCheckedThrowingContinuation { continuation in
            do {
                try Process.run(processURL, arguments: arguments) { process in
                    continuation.resume()
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
        
        return outputURL
    }
    
    private var data: String {
        // let filename = "Sample25"
        let filename = "Day25"
        let inputURL = Bundle.main.url(forResource: filename, withExtension: "txt")!
        return try! String(contentsOf: inputURL)
    }
    
    private func generateGraphFile(isSample: Bool = false) throws -> URL {
        let data = self.data
        
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appending(path: "Day25Input.dot")
        
        try? FileManager.default.removeItem(at: outputURL)
        FileManager.default.createFile(atPath: outputURL.path(percentEncoded: false), contents: nil)
        
        let file = try FileHandle(forWritingTo: outputURL)
        
        try write("graph G {", to: file)
        
        for line in data.split(separator: "\n") {
            let parts = line.split(separator: ": ")
            let name = String(parts[0])
            let otherNames = parts[1].split(separator: " ").map { String($0) }
            
            try write("  \(name) -- { \(otherNames.joined(separator: " ")) }", to: file)
        }
        
        try write("}", to: file)
        
        try file.close()
        
        return outputURL
    }
    
    private func generateGraph(from inputURL: URL) async throws -> URL {
        let processURL = URL(fileURLWithPath: "/opt/homebrew/Cellar/graphviz/9.0.0/bin/dot")
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appending(path: "Day25.pdf")
        
        let arguments = [
            "-Tpdf",
            "-Ksfdp",
            inputURL.path(percentEncoded: false),
            "-o",
            outputURL.path(percentEncoded: false)
        ]
        
        try await withCheckedThrowingContinuation { continuation in
            do {
                try Process.run(processURL, arguments: arguments) { process in
                    continuation.resume()
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
        
        return outputURL
    }
    
    private func write(_ string: String, to file: FileHandle) throws {
        let line = string + "\n"
        let data = line.data(using: .utf8)!
        try file.write(contentsOf: data)
    }
    
    private func makeGroups(lines: Set<Line>, maxCount: Int = 2) -> [Set<String>]? {
        var remaining: Set<String> = []
        
        for line in lines {
            remaining.insert(line.lhs)
            remaining.insert(line.rhs)
        }
        
        var results: [Set<String>] = []
        var currentGroup: Set<String> = []
        
        while !remaining.isEmpty {
            let startNode = remaining.removeFirst()

            var toVisit: Set<String> = [startNode]
            
            while !toVisit.isEmpty {
                let current = toVisit.removeFirst()
                currentGroup.insert(current)
                remaining.remove(current)
                
                let neighbors = lines
                    .filter { $0.lhs == current || $0.rhs == current }
                    .map { $0.lhs == current ? $0.rhs : $0.lhs }
                    .filter { !currentGroup.contains($0) }
                
                for neighbor in neighbors {
                    toVisit.insert(neighbor)
                }
            }
            
            results.append(currentGroup)
            currentGroup.removeAll()
            
            if results.count == maxCount && !remaining.isEmpty {
                return nil
            }
        }
        
        return results
    }
    
    struct Line: Hashable, CustomDebugStringConvertible {
        var lhs: String
        var rhs: String
        
        var debugDescription: String {
            "[ \(lhs) - \(rhs) ]"
        }
    }
    
    private func calculate() async throws -> Int {
        var lines: Set<Line> = []
        
        for line in data.split(separator: "\n") {
            let parts = line.split(separator: ": ")
            let name = String(parts[0])
            let otherNames = parts[1].split(separator: " ").map { String($0) }
            
            for otherName in otherNames {
                let sorted = [name, otherName].sorted()
                let line = Line(lhs: sorted[0], rhs: sorted[1])
                lines.insert(line)
            }
        }
        
        let pair1 = [lhs1, rhs1].sorted()
        let pair2 = [lhs2, rhs2].sorted()
        let pair3 = [lhs3, rhs3].sorted()
        
        let excluded = [
            lines.first(where: { $0.lhs == pair1[0] && $0.rhs == pair1[1] })!,
            lines.first(where: { $0.lhs == pair2[0] && $0.rhs == pair2[1] })!,
            lines.first(where: { $0.lhs == pair3[0] && $0.rhs == pair3[1] })!
        ]
        
        let cutLines = lines.subtracting(excluded)
        
        guard let groups = makeGroups(lines: cutLines) else {
            throw CalculationError.failed
        }
        
        guard groups.count == 2 else {
            throw CalculationError.failed
        }
        
        return groups[0].count * groups[1].count
    }
}

#Preview {
    ContentView()
}
