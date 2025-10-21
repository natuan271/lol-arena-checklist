//
//  ChampionView.swift
//  LolArenaChecklist
//
//  Created by Tunx on 21/10/25.
//

import SwiftUI

struct ChampionView: View {
    let champion: Champion
    let imageVersion: String
    let completed: Bool
    let isSelecting: Bool
    let onTap: (Bool?) -> Void

    var body: some View {
        VStack {
            if let url = champion.imageURL(version: imageVersion) {
                AsyncCachedImage(url: url)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .overlay {
            if completed {
                Rectangle()
                    .stroke(.yellow, lineWidth: 1)
                    .overlay(alignment: .bottom) {
                        Image(systemName: "checkmark.circle.fill")
                            .bold()
                            .foregroundStyle(.yellow)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .frame(width: 64, height: 64)
                            .offset(y: 32)
                    }
            }
        }
        .overlay(alignment: .topTrailing) {
            if isSelecting {
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .overlay(alignment: .bottom) {
                        Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                            .bold()
                            .foregroundStyle(completed ? .yellow : .gray)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .frame(width: 64, height: 64)
                            .offset(y: 32)
                    }
                    .onTapGesture {
                        onTap(nil)
                    }
            } else {
                Menu {
                    Button {
                        onTap(true)
                    } label: {
                        Text("Completed")
                    }
                    Button {
                        onTap(false)
                    } label: {
                        Text("Uncompleted")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                        .padding(8)
                        .clipShape(.circle)
                        .glassEffect()
                        .padding(2)
                }
            }
        }
    }
}
