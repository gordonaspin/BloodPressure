//
//  Extensions.swift
//  Sailing
//
//  Created by Gordon Aspin on 1/8/25.
//

import SwiftUI

public func print(_ items: String..., filename: String = #file, function : String = #function, line: Int = #line, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let pretty = "\(Date().toTimestamp): \(URL(fileURLWithPath: filename).lastPathComponent).\(line) \(function): "
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(pretty+output, terminator: terminator)
    #else
        Swift.print("RELEASE MODE")
    #endif
}

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let pretty = "\(Date().toTimestamp): "
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(pretty+output, terminator: terminator)
    #else
        Swift.print("RELEASE MODE")
    #endif
}

extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}

extension Date {

    var toTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd H:mm:ss.SSS"
        return formatter.string(from: self)
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Bundle {
    // Application name shown under the application icon.
    var applicationName: String? {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
// swipe() extension on any view. Example:
//    var body: some View {
//    Text("Hello, World!")
//        .swipe(
//           up: {
//            doUp()
//            },
//           down: {
//            doDown()
//            })/
//           left: {
//            doLeft()
//            },
//           right: {
//            doRight()
//            })/
//}

extension View {
    func swipe(
        up:     @escaping (() -> Void) = {},
        down:   @escaping (() -> Void) = {},
        left:   @escaping (() -> Void) = {},
        right:  @escaping (() -> Void) = {}
    ) -> some View {
        return self.gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onEnded({
                value in
                if abs(value.translation.width) < abs(value.translation.height) {
                    // dominant motion was up/down
                    if value.translation.height < 0 {
                        up() }
                    if value.translation.height > 0 {
                        down() }
                }
                else {
                    if value.translation.width < 0 {
                        left() }
                    if value.translation.width > 0 {
                        right() }
                }
            }))
    }
}

extension View {
    func wiggling() -> some View {
        modifier(WiggleModifier())
    }
}

struct WiggleModifier: ViewModifier {
    @State private var isWiggling = false
    
    private static func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }
    
    private let rotateAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.14,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)
    
    private let bounceAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.18,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? 2.0 : 0))
            .animation(rotateAnimation, value: isWiggling)
            .offset(x: 0, y: isWiggling ? 2.0 : 0)
            .animation(bounceAnimation, value: isWiggling)
            .onAppear() { isWiggling.toggle() }
    }
}
