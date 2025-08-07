//
//  MultipleSelectionRow.swift
//  TjuTju
//
//  Created by Vidas Sun on 05/08/2025.
//
//  A reusable view component that displays a title and a checkmark
//  to indicate selection. Tapping the row executes a provided action.
//

import SwiftUI

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    // Example preview for the component
    Form {
        MultipleSelectionRow(title: "Selected Item", isSelected: true) {}
        MultipleSelectionRow(title: "Unselected Item", isSelected: false) {}
    }
}
