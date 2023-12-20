//
//  Tips.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/20/23.
//

import Foundation
import SwiftUI
import TipKit





struct CustomStampTip: Tip {
    
    var title: Text {
        Text("Customize Your Stamp")
    }

    var message: Text? {
        Text("Define a custom stamp by choosing its color and symbol. Stamped entries will display your selected color and icon until re-stamped or unstamped. Limited to 4 active stamps at a time to avoid clutter.")
    }
    

//    var image: Image? {
//        Image(systemName: "info.circle.fill")
//    }
}

