//
//  ErrorStateView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.theme.danger)
            
            Text("Terjadi Kesalahan")
                .font(.app.title)
                .foregroundColor(.theme.textPrimary)
            
            Text(message)
                .font(.app.body)
                .foregroundColor(.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            PrimaryButtonComponent(title: "Try Again", action: retryAction)
                .frame(width: 200)
                .padding(.top, 8)
        }
        .padding()
    }
}
