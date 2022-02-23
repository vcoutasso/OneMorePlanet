import CoreGraphics

enum WorldLayer: CGFloat {
    case background = -100
    case nebulas = -90
    case stars = -80
    case interactable = 0
    case player = 50
    case overlay = 100

    static var allLayers = [background, nebulas, stars, interactable, player, overlay]
}
