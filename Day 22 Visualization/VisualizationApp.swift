//
//  VisualizationApp.swift
//  Advent of Code 2023 Day 22 Visualization
//
//  Created by Stephen H. Gerstacker on 2023-12-23.
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import Visualization

@main
struct VisualizationApp: App {
    
    @State var context: SolutionContext = VisualizationContext(width: 1400, height: 1400, frameRate: 60.0)
    
    var body: some Scene {
        WindowGroup {
#if os(macOS)
            SolutionView()
                .environment(context)
                .navigationTitle(context.name)
#else
            NavigationStack {
                SolutionView()
                    .environment(context)
                    .navigationTitle(context.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea(.all, edges: [.bottom])
            }
#endif
        }
    }
}
