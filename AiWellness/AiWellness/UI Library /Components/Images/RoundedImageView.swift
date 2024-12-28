//
//  RoundedImageView.swift
//  AiWellness
//
//  Created by Kazakuba on 27.12.24..
//


import SwiftUI

struct RoundedImageView: View {
    let image: Image
    let placeholder: Image
    let isLoaded: Bool

    var body: some View {
        if isLoaded {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// Example Usage:
struct RoundedImageView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedImageView(
            image: Image(systemName: "photo"),
            placeholder: Image(systemName: "photo.fill"),
            isLoaded: false
        )
        .frame(width: 100, height: 100)
    }
}