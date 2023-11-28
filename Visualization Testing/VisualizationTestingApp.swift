//
//  VisualizationTestingApp.swift
//  Advent of Code 2023 Visualization Testing
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import Visualization

@main
struct VisualizationTestingApp: App {
    
    @State var context: SolutionContext = VisualizationTestingContext(width: 800, height: 800, frameRate: 60.0)
    
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
