//
//  PDFViewer.swift
//  Advent of Code 2023 - Day 25
//
//  Created by Stephen H. Gerstacker on 2023-12-30.
//  SPDX-License-Identifier: MIT
//

import PDFKit
import SwiftUI

struct PDFViewer: NSViewRepresentable {
    
    var data: Data?
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        if let data {
            pdfView.document = PDFDocument(data: data)
        }
        
        pdfView.autoScales = true
        
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {
        if let data {
            nsView.document = PDFDocument(data: data)
        } else {
            nsView.document = nil
        }
    }
    
}
