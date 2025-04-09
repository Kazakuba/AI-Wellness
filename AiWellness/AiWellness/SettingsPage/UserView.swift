//
//  AccountSectionView.swift
//  AiWellness
//
//  Created by Lucija Iglič on 10. 2. 25.
//

import SwiftUI

struct UserView: View {
    let user: User?
    
    var body: some View {
        Section {
            if let user = user {
                HStack {
                    AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            } else {
                Text("Not logged in")
                    .foregroundColor(.gray)
            }
        }
    }
}
