////
////  MediaView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 10/27/23.
////
//
//import Foundation
//import SwiftUI
//import PhotosUI
//
//enum MediaType {
//    case gif(URL)
//    case livePhoto(imageURL: URL, videoURL: URL)
//}
//
//struct MediaView: View {
//    var mediaType: MediaType
//
//    @State private var livePhoto: PHLivePhoto?
//
//    var body: some View {
//        switch mediaType {
//        case .gif(let url):
//            AnimatedImageView(url: url)
//        case .livePhoto(let imageURL, let videoURL):
//            if let lp = livePhoto {
//                LivePhotoView(livephoto: .constant(lp))
//            } else {
//                // Provide a placeholder or fallback view if needed
//                Color.gray.onAppear {
//                    loadLivePhoto(imageURL: imageURL, videoURL: videoURL)
//                }
//            }
//        }
//    }
//
//    private func loadLivePhoto(imageURL: URL, videoURL: URL) {
//        PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL], placeholderImage: nil, targetSize: CGSize.zero, contentMode: .aspectFit) { (livePhoto, info) in
//            self.livePhoto = livePhoto
//        }
//    }
//}
//// Your existing AnimatedImageView and LivePhotoView code goes here...
//
//
//struct LivePhotoView: UIViewRepresentable {
//    @Binding var livephoto: PHLivePhoto
//
//    func makeUIView(context: Context) -> PHLivePhotoView {
//        return PHLivePhotoView()
//    }
//
//    func updateUIView(_ lpView: PHLivePhotoView, context: Context) {
//        lpView.livePhoto = livephoto
//    }
//}
//
//
//// 1. Saving a Live Photo
//func saveLivePhoto(livePhoto: PHLivePhoto, completion: @escaping (URL?, URL?) -> Void) {
//    // You would typically use PHLivePhoto.requestExportSession to get both HEIC and MOV assets.
//    // Save both assets to your desired location (e.g., documents directory).
//    // Call the completion handler with the saved file URLs.
//}
//
//// 2. Loading a Live Photo
//func loadLivePhoto(heicURL: URL, movURL: URL, completion: @escaping (PHLivePhoto?) -> Void) {
//    PHLivePhoto.request(withResourceFileURLs: [heicURL, movURL], placeholderImage: nil, targetSize: CGSize.zero, contentMode: .aspectFit) { livePhoto, info in
//        completion(livePhoto)
//    }
//}
//
//// 3. Displaying a Live Photo in a SwiftUI view
//struct LivePhotoDisplayView: UIViewRepresentable {
//    var heicURL: URL
//    var movURL: URL
//
//    func makeUIView(context: Context) -> PHLivePhotoView {
//        return PHLivePhotoView()
//    }
//
//    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
//        loadLivePhoto(heicURL: heicURL, movURL: movURL) { livePhoto in
//            uiView.livePhoto = livePhoto
//        }
//    }
//}
