//
//  ContentView.swift
//  Example
//
//  Created by Lorpaves on 2025/4/19.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    var body: some View {
        NavigationView {
            List {
                Link(destination: URL(string: "example://open/userInfo?type=modal")!) {
                    Text("example://open/userInfo?type=modal")
                }
                Link(destination: URL(string: "example://open/userInfo?type=push")!) {
                    Text("example://open/userInfo?type=push")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
