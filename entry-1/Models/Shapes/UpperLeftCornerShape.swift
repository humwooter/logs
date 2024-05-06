//
//  UpperLeftCornerShape.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 5/6/24.
//

import Foundation
import SwiftUI

struct UpperLeftCornerShape: Shape {
    var cornerRadius: CGFloat
    var extendLengthX: CGFloat // Length to extend the line segments
    var extendLengthY: CGFloat // Length to extend the line segments

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the intersection of the extended vertical and the curve
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius + extendLengthY))

        // Draw the curve
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        // Extend the horizontal line
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius + extendLengthX, y: rect.minY))

        return path
    }
}
