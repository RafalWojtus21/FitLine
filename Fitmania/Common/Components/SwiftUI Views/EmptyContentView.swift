//
//  EmptyContentView.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 23/01/2024.
//

import SwiftUI

struct EmptyContentView: View {
    var body: some View {
        ZStack {
            Color(.primaryColor)
            ContentUnavailableView("You don't have any notifications scheduled", systemImage: "bell.badge")
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    EmptyContentView()
}
