//
//  SpeechRecognizer.swift
//  entry-1
//
//  Created by Katya Raman on 8/19/23.
//

import Foundation
import Speech
import AVFoundation

//class SpeechRecognizer {
//
//  let speechRecognizer = SFSpeechRecognizer()
//  var recognitionTask: SFSpeechRecognitionTask?
//
//  func startRecognition(onFinalResult: @escaping (String) -> Void) {
//    
//    // Cancel previous task if running
//    recognitionTask?.cancel()
//    
//    let audioSession = AVAudioSession.sharedInstance()
//    try! audioSession.setCategory(AVAudioSession.Category.record)
//
//    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
//      
//      guard let transcription = result?.bestTranscription.formattedString else {
//        return
//      }
//      
//      onFinalResult(transcription)
//    }
//
//  }
//  
//  func finishRecognition() {
//   
//    recognitionTask?.finish()
//    recognitionTask = nil
//
//  }
//
//}
