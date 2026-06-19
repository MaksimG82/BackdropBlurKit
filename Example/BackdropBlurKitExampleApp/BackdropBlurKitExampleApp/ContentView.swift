//
//  ContentView.swift
//  BackdropBlurKitExampleApp
//
//  Created by Maksim Gaisin on 19.06.26.
//

import SwiftUI
import BackdropBlurKit

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<2000) { i in
                        Text("Item \(i)")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }

            VStack(spacing: 40) {
                Text("Floating Element 1")
                    .padding(30)
                    .background(.white.opacity(0.9))
                    .cornerRadius(15)
                    .blurred(cornerRadius: 15)

                Text("Floating Element 2")
                    .padding(40)
                    .background(.white.opacity(0.9))
                    .cornerRadius(30)
                    .blurred(cornerRadius: 30)
            }
        }
        .blurSource()
    }
}

#Preview {
    ContentView()
}
