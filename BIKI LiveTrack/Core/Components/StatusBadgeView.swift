//
//  StatusBadgeView.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

struct StatusBadgeView: View {
    let status: String
    
    var body: some View {
        Text(status.uppercased())
            .font(.caption).bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(status == "Active" ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundColor(status == "Active" ? .green : .gray)
            .cornerRadius(8)
    }
}
