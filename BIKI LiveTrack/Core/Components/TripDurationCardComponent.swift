//
//  TripDurationCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct TripDurationCardComponent: View {
    var duration: String
    var origin: AnyView // Diubah menjadi AnyView
    var destination: AnyView // Diubah menjadi AnyView
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Text("Trip Duration")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.theme.textSecondary)
                
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
            
            Text(duration)
                .font(.system(size: 60, weight: .regular))
                .monospacedDigit()
                .foregroundColor(Color.theme.textPrimary)

            HStack {
                // Langsung memanggil origin sebagai View
                origin
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                // Langsung memanggil destination sebagai View
                destination
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding(24)
        .frame(width: 469, height: 189)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 4)
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()
        
        TripDurationCardComponent(
            duration: "10:45:09",
            // Preview disesuaikan agar mengirimkan AnyView
            origin: AnyView(Text("BIKI point SMG")),
            destination: AnyView(Text("Ranch Market BSD"))
        )
        .padding()
    }
}
