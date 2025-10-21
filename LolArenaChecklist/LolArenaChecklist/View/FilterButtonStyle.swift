//
//  FilterButtonStyle.swift
//  LolArenaChecklist
//
//  Created by Tunx on 21/10/25.
//
import SwiftUI

struct FilterButtonStyle: ButtonStyle {
    var selected: Bool
    init(is selected: Bool) {
        self.selected = selected
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                selected
                ? AnyShapeStyle(.selection)
                : AnyShapeStyle(.fill.quaternary)
            )
            .foregroundStyle(
                selected
                ? AnyShapeStyle(.background)
                : AnyShapeStyle(.foreground)
            )
            .clipShape(Capsule())
    }
}
