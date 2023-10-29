//
//  PasswordView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/28/23.
//

import Foundation
import SwiftUI

struct PasswordView: View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    let systemImages = ["house.fill", "star.fill", "heart.fill",
                        "bell.fill", "magnifyingglass", "sun.max.fill",
                        "moon.fill", "cloud.fill", "bookmark.fill"]
    @State var password: [String] = []
    
    var body: some View {
        VStack {
            Text("Enter Password")
            
            LazyVGrid(columns: columns) {
                ForEach(systemImages, id: \.self) { image in
                    Button(action: {
                        password.append(image)
                    }) {
                        Image(systemName: image)
                            .font(.title)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Button(action: {
                if !password.isEmpty {
                    password.removeLast()
                }
            }) {
                Image(systemName: "delete.left.fill")
                    .font(.title)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.2)))
                    .foregroundColor(.red)
            }
            
            Text("Password: \(password.joined(separator: ", "))")
        }
        .padding()
    }
}


