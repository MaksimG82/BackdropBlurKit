//
//  SimpleScrollView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 30.06.26.
//

import SwiftUI
import BackdropBlurKit

/// A vertically scrolling checkerboard background with a fixed blurred panel,
/// demonstrating the basic capture-and-blur pipeline.
struct SimpleScrollView: View {

    var body: some View {
        ZStack() {
            scrollingBackdrop
                .ignoresSafeArea()
                .blurSource()

            targetView
                .blurred()
        }.blurCoordinator().ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension SimpleScrollView {
    
    var scrollingBackdrop: some View {
        ScrollView {
            CheckerboardBackground()
                .frame(height: 2000)
                
        }
    }
    
    
    /// A fixed panel rendered above the scrolling content.
    var targetView: some View {
        Text("Fixed target view")
            .font(.headline)
            .padding(100)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
    }
}

#Preview {
    SimpleScrollView()
}
