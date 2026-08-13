//
//  TripDurationCardComponent.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 10/08/26.
//

import SwiftUI

struct TripDurationCardComponent: View {
    var duration: String
    var origin: String
    var destination: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Text("Trip Duration")
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
                .font(.system(size: 64, weight: .regular))
                .monospacedDigit()
                .foregroundColor(Color.theme.textPrimary)
                .padding(.vertical, 4)
            
            HStack {
                Text(origin)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                Text(destination)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(15)
    }
}

#Preview {
    ZStack {
        Color.theme.tertiaryGreen.ignoresSafeArea()
        
        TripDurationCardComponent(
            duration: "10:45:09",
            origin: "BIKI point SMG",
            destination: "Ranch Market BSD"
        )
        .padding()
    }
}
