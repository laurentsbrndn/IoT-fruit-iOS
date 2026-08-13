//
//  ContentView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var isSidebarVisible: Bool = false
    
    var body: some View {
        VStack {
            switch selectedTab {
            case .home:
                HomeView()
            case .shipmentHistory:
                ShipmentHistoryView()
            }
        }
        .padding(.top, 80)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.tertiaryGreen.ignoresSafeArea())
        .overlay(
            VStack {
                HStack(alignment: .top) {
                    if !isSidebarVisible {
                        Spacer()
                    }
                    
                    AppNavigationBarComponent(selectedTab: $selectedTab, isSidebarVisible: $isSidebarVisible)
                        .padding(.leading, isSidebarVisible ? 16 : 0)
                    
                    Spacer(minLength: 0)
                }
                Spacer()
            }
            .padding(.top, 16)
        )
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}
