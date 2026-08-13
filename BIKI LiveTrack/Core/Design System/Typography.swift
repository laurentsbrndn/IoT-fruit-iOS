//
//  Typography.swift
//  BIKI LiveTrack
//
//  Created by Laurentius Brandon Vikario on 06/08/26.
//

import SwiftUI

extension Font {
    static let app = AppTypography()
}

struct AppTypography {
    let heading1 = Font.system(size: 34, weight: .bold, design: .rounded)
    let heading2 = Font.system(size: 28, weight: .bold, design: .rounded)
    let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    let title1 = Font.system(size: 18, weight: .semibold)
    let body = Font.system(size: 16, weight: .regular)
    let bodyBold = Font.system(size: 16, weight: .semibold)
    let caption = Font.system(size: 14, weight: .regular)
    let captionBold = Font.system(size: 14, weight: .medium)
}
