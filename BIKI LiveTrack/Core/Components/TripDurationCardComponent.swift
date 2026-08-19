//
//  TripDurationCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct TripDurationCardComponent: View {
    var duration: String
    var origin: AnyView
    var destination: AnyView
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Trip Duration and Location")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.theme.textSecondary)
                
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
            
            Text(duration)
                .font(.system(size: 56, weight: .regular))
                .monospacedDigit()
                .minimumScaleFactor(0.5) 
                .lineLimit(1)
                .foregroundColor(Color.theme.textPrimary)
                .padding(.vertical, 4)
            
            HStack {
                // Langsung memanggil origin sebagai View
                origin
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color.theme.textSecondary)
                    .layoutPriority(1)
                
                Spacer()
                
                // Langsung memanggil destination sebagai View
                destination
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(24)
        .frame(height: 209)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(
            color: .black.opacity(0.08),
            radius: 4,
            y: 4
        )
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()
        
        TripDurationCardComponent(
            duration: "10:45:09",
            // Preview disesuaikan agar mengirimkan AnyView
            origin: AnyView(Text("Jalan Tambara No. 85, Semarang")),
            destination: AnyView(Text("National Monument, Central Jakarta"))
        )
        .padding()
    }
}
