import CoreGraphics

enum WorldLayer: CGFloat {
    case background = -100
    case game = 0
    case player = 10
    case overlay = 100

    static var allLayers = [background, game, player, overlay]
}
