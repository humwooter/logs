//
//  ButtonViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/1/24.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import LocalAuthentication
import UniformTypeIdentifiers


struct ToggleButton: View {
    @Binding var isOn: Bool
    var color: Color
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: color))
    }
    
}




struct BackupButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: UIFont.systemFontSize))
            .padding(15)
            .padding(.horizontal, 10)
            .background {
                LinearGradient(colors: [.green, .cyan], startPoint: .leading, endPoint: .trailing)
            }
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}

struct RestoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: UIFont.systemFontSize))
            .padding(15)
            .padding(.horizontal, 10)
            .background {
                LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
            }
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}


