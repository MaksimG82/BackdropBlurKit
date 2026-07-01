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
            ZStack {
                LinearGradient(colors: [.red, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        ForEach(0..<200) { i in
                            Text("Item \(i)")
                                .padding()
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .blurSource()

            VStack(spacing: 40) {
                
                Text("Floating Element 1")
                    .padding(30)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.blue, lineWidth: 1)
                    )
                    .blurred(cornerRadius: 15)
                
                
                Text("Floating Element 1")
                    .padding(30)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.blue, lineWidth: 1)
                    )

                Text("Floating Element 2")
                    .padding(40)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.blue, lineWidth: 1)
                    )
                    .blurred(cornerRadius: 30)
                    
            }
        }
        .ignoresSafeArea()
        .blurCoordinator()
    }
}

#Preview {
    ContentView()
}
