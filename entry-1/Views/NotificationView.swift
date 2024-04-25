//
//  NotificationView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/24/24.
//

import Foundation

import SwiftUI

struct NotificationView: View {
    var message: String
    var iconName: String?
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            HStack {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(.white)
                        .padding(.leading)
                }
                Text(message).font(.system(size: UIFont.systemFontSize))
                    .foregroundColor(.white)
                    .padding(.all)
            }
            .background(Color.green) // Change color based on notification type if needed
            .cornerRadius(30)
            .shadow(radius: 10)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Dismiss after 2 seconds
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}
