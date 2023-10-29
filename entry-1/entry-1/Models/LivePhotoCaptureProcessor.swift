//
//  LivePhotoCaptureProcessor.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI
import Photos
import AVFoundation


class LivePhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    
    var stillImageData: Data?
    var saveCompletion: ((URL?, Error?) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing Live Photo still: \(error!)")
            return
        }
        
        stillImageData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else {
            print("Error capturing Live Photo movie: \(error!)")
            return
        }
        
        guard let imageData = stillImageData else { return }
        
        let savedURL = saveLivePhotoToAppFiles(stillImageData: imageData, livePhotoMovieURL: outputFileURL)
        saveCompletion?(savedURL, nil)
    }
    
    private func saveLivePhotoToAppFiles(stillImageData: Data, livePhotoMovieURL: URL) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let uniqueFilename = UUID().uuidString
        let imageFileURL = documentsDirectory.appendingPathComponent("\(uniqueFilename).jpg")
        let movieFileURL = documentsDirectory.appendingPathComponent("\(uniqueFilename).mov")
        
        do {
            try stillImageData.write(to: imageFileURL)
            try FileManager.default.copyItem(at: livePhotoMovieURL, to: movieFileURL)
        } catch {
            print("Error saving Live Photo: \(error)")
            return nil
        }
        
        return imageFileURL
    }
}

