import CoreGraphics

enum WorldLayer: CGFloat {
    case bottom = -100
    case middle = 0
    case top = 100

    static var allLayers = [bottom, middle, top]
}
