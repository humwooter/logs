//
//  ThumbnailProvider.swift
//  ThemeThumbnailExtension
//
//  Created by Katyayani G. Raman on 8/18/24.
//

import UIKit
import QuickLookThumbnailing

class ThumbnailProvider: QLThumbnailProvider {
    
    class ThumbnailProvider: QLThumbnailProvider {

        override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
                // Example: Generate a basic thumbnail image
                let size = request.maximumSize
                let renderer = UIGraphicsImageRenderer(size: size)
                let thumbnail = renderer.image { context in
                    UIColor.lightGray.setFill()
                    context.fill(CGRect(origin: .zero, size: size))
                    let text = "Thumbnail"
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 20),
                        .foregroundColor: UIColor.white
                    ]
                    let textSize = text.size(withAttributes: attributes)
                    let textRect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
                    text.draw(in: textRect, withAttributes: attributes)
                }

                handler(QLThumbnailReply(contextSize: size, currentContextDrawing: { () -> Bool in
                    thumbnail.draw(in: CGRect(origin: .zero, size: size))
                    return true
                }), nil)
            }
//        override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
//            print("ENTERED PRIVIDE THUMBNAIL")
//
//            // Use your method to generate a thumbnail image from the .themePkg content
//            guard let thumbnailImage = generateThumbnail(for: request.fileURL, maximumSize: request.maximumSize) else {
//                handler(nil, NSError(domain: "com.yourapp.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate thumbnail"]))
//                return
//            }
//
//            // Draw the thumbnail into the current context using UIKit's coordinate system
//            handler(QLThumbnailReply(contextSize: request.maximumSize, currentContextDrawing: { () -> Bool in
//                thumbnailImage.draw(in: CGRect(origin: .zero, size: request.maximumSize))
//                return true
//            }), nil)
//        }

        private func generateThumbnail(for url: URL, maximumSize: CGSize) -> UIImage? {
            // Logic to generate the thumbnail image from the .themePkg contents
            // This could be as simple as loading an image file stored within the .themePkg
            // or more complex like rendering a view or processing the content.

            // Example: load an image from inside the .themePkg (assuming it's unzipped)
            let fileManager = FileManager.default
            let thumbnailPath = url.appendingPathComponent("thumbnail.png").path

            if fileManager.fileExists(atPath: thumbnailPath) {
                return UIImage(contentsOfFile: thumbnailPath)
            }

            // Alternatively, render a thumbnail based on other contents
            // or generate a default placeholder if none exists
            return UIImage(named: "defaultThumbnail")  // Fallback
        }
    }
}
