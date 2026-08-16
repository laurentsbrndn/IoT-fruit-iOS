//
//  ContentView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab? = .home
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
            List(AppTab.allCases, id: \.self, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    HStack(spacing: 16) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 260, max: 300)
            
        } detail: {
            
            NavigationStack {
                ZStack {
                    Color.theme.tertiaryGreen.ignoresSafeArea()
                    
                    if let selectedTab = selectedTab {
                        switch selectedTab {
                        case .home:
                            HomeView()
                        case .shipmentHistory:
                            ShipmentHistoryView()
                        }
                    } else {
                        Text("Pilih menu dari sidebar")
                            .foregroundColor(.secondary)
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
