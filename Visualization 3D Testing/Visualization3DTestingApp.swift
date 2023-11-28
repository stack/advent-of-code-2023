//
//  Visualization3DTestingApp.swift
//  Advent of Code 2023 Visualization 3D Testing
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import Visualization

@main
struct Visualization3DTestingApp: App {
    
    @State var context: SolutionContext = Visualization3DTestingContext(width: 1920, height: 1080, frameRate: 60.0)
    @State private var selectedMode: Visualization3DTestingContext.Mode = .boxes
    
    var body: some Scene {
        
        WindowGroup {
#if os(macOS)
            SolutionView()
                .environment(context)
                .navigationTitle(context.name)
                .toolbar(content: {
                    ToolbarItem {
                        Menu(modeTitle(for: selectedMode)) {
                            ForEach(Visualization3DTestingContext.Mode.allCases) { mode in
                                Button(action: { select(mode: mode) }, label: { Text(modeTitle(for: mode)) })
                            }
                        }
                    }
                })
#else
            NavigationStack {
                SolutionView()
                    .environment(context)
                    .navigationTitle(context.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea(.all, edges: [.bottom])
                    .toolbar(content: {
                        ToolbarItem {
                            Menu(modeTitle(for: selectedMode)) {
                                ForEach(Visualization3DTestingContext.Mode.allCases) { mode in
                                    Button(action: { select(mode: mode) }, label: { Text(modeTitle(for: mode)) })
                                }
                            }
                        }
                    })
            }
#endif
        }
    }
    
    private func modeTitle(for mode: Visualization3DTestingContext.Mode) -> String {
        switch mode {
        case .boxes:
            return "Boxes"
        case .spheres:
            return "Spheres"
        case .metalSpheres:
            return "Metal Spheres"
        case .stoneBlock:
            return "Stone Block"
        case .vikingRoom:
            return "Viking Room"
        case .shiba:
            return "Shiba"
        case .chaos:
            return "Chaos"
        case .instances:
            return "Instances"
        case .fancyBoxes:
            return "Fancy Boxes"
        case .generatedTextures:
            return "Generated Textures"
        }
    }
    
    private func select(mode: Visualization3DTestingContext.Mode) {
        guard let context = context as? Visualization3DTestingContext else {
            return
        }
        
        context.mode = mode
        selectedMode = mode
    }
}
