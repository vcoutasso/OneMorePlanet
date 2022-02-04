import CoreGraphics

enum WorldLayer: CGFloat {
    case background = -100
    case planets = 0
    case player = 100
    case overlay = 1000

    static var allLayers = [background, planets, player, overlay]
}
