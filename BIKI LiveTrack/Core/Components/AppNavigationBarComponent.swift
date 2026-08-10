//
//  AppNavigationBarComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct AppNavigationBarComponent: View {
    @Binding var selectedTab: AppTab
    @Binding var isSidebarVisible: Bool
    
    var body: some View {
        Group {
            if isSidebarVisible {
                sidebarStyle
            } else {
                pillStyle
            }
        }
    }
    
    var pillStyle: some View {
        HStack(spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isSidebarVisible.toggle()
                }
            }) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .frame(height: 20)
            
            HStack(spacing: 4) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation { selectedTab = tab }
                    }) {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .blue : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.trailing, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    var sidebarStyle: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isSidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation { selectedTab = tab }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18))
                                .frame(width: 24)
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .foregroundColor(selectedTab == tab ? .blue : .primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(width: 260)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 0)
        .frame(maxHeight: .infinity)
    }
}
