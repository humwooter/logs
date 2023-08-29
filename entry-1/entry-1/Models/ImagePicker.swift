//
//  ImagePicker.swift
//  entry-1
//
//  Created by Katya Raman on 8/19/23.
//

import Foundation
import SwiftUI
import UIKit



struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        print("entered func makeUIViewController)")
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need to update anything here
    }

    func makeCoordinator() -> Coordinator {
        print("entered func makeCoordinator)")
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            print("entered func init(_ parent: ImagePicker)")

            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
           print("entered func imagePickerController")
            if let image = info[.originalImage] as? UIImage {
    
                if let cgImage = image.cgImage { // to preserve the orientation of the camera image
                    let orientedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                    parent.selectedImage = orientedImage
                }
                print("assigned selectedImage to parent.selectedImage")

            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("entered func imagePickerControllerDidCancel")
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
