//
//  VIsualBlurEffect.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//

import SwiftUI
import UIKit

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var vibrancyStyle: UIVibrancyEffectStyle?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        if let vibrancyStyle = vibrancyStyle {
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            visualEffectView.contentView.addSubview(vibrancyView)
            vibrancyView.frame = visualEffectView.bounds
            vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        return visualEffectView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
