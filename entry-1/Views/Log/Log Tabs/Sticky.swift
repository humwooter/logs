//
//  Sticky.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/15/24.
//

import SwiftUI

struct Sticky: ViewModifier {
    @State private var frame: CGRect = .zero
    var stickyRects: [CGRect] = []

    // Check if the view should be sticking
    var isSticking: Bool {
        frame.minY < 0
    }

    // Calculate the offset
    var offset: CGFloat {
        guard isSticking else { return 0 }
        var o = -frame.minY
        if let idx = stickyRects.firstIndex(where: { $0.minY > frame.minY && $0.minY < frame.height }) {
            let other = stickyRects[idx]
            o -= frame.height - other.minY
        }
        return o
    }

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .zIndex(isSticking ? 1 : 0)
            .overlay(
                GeometryReader { proxy in
                    let f = proxy.frame(in: .named("container"))
                    Color.clear
                        .onAppear { frame = f }
                        .onChange(of: f) { frame = $0 }
                        .preference(key: FramePreference.self, value: [frame])
                }
            )
    }
}

extension View {
    func sticky(_ stickyRects: [CGRect]) -> some View {
        self.modifier(Sticky(stickyRects: stickyRects))
    }
}


struct FramePreference: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ScrollViewReaders<Content: View>: View {
    let content: (ScrollViewProxy, ScrollViewProxy) -> Content

    var body: some View {
        ScrollViewReader { proxy1 in
            ScrollViewReader { proxy2 in
                content(proxy1, proxy2)
            }
        }
    }
}
