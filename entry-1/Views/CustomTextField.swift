//
//  CustomTextField.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 1/4/24.
//

import Foundation
import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
       var placeholder: String
       @State private var height: CGFloat = 0

       func makeUIView(context: Context) -> UITextField {
           let textField = UITextField(frame: .zero)
           textField.delegate = context.coordinator
           textField.placeholder = placeholder
           textField.borderStyle = .roundedRect
           textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
           textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
           textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
           return textField
       }

       func updateUIView(_ uiView: UITextField, context: Context) {
           uiView.text = text
           DispatchQueue.main.async {
               self.height = uiView.sizeThatFits(CGSize(width: uiView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
           }
       }

       class Coordinator: NSObject, UITextFieldDelegate {
           var parent: CustomTextField

           init(_ parent: CustomTextField) {
               self.parent = parent
           }

           @objc func textFieldDidChange(_ textField: UITextField) {
               parent.text = textField.text ?? ""
           }
       }

       func makeCoordinator() -> Coordinator {
           Coordinator(self)
       }
   }
