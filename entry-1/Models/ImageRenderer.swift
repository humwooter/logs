//
//  ImageRenderer.swift
//  entry-1
//
//  Created by Katya Raman on 9/18/23.
//

import Foundation
import SwiftUI


class ImageRenderer<Content: View> {
    private let content: Content
    private let size: CGSize

    init(content: Content, size: CGSize = CGSize(width: 500, height: 500)) {
        self.content = content
        self.size = size
    }

    func render(action: (CGSize, (CGContext) -> Void) -> Void) {
        let controller = UIHostingController(rootView: content)
        controller.view.bounds = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }

        if let cgImage = image.cgImage {
            action(size, { context in
                context.draw(cgImage, in: CGRect(origin: .zero, size: size))
            })
        }
    }
}
