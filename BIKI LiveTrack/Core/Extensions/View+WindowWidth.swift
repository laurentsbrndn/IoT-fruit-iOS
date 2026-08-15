//
//  View+WindowWidth.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 16/08/26.
//
//

import SwiftUI
import UIKit

extension View {
    var windowWidth: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: { $0.isKeyWindow })?
            .bounds.width
            ?? UIScreen.main.bounds.width
    }
}
