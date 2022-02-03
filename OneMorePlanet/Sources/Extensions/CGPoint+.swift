import SpriteKit
import CoreGraphics

extension CGPoint {
    init(x: Float, y: Float) {
        self.init(x: CGFloat(x),
                  y: CGFloat(y))
    }

    init(_ vector: vector_float2) {
        self.init(x: vector.x, y: vector.y)
    }

    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
  left = left - right
}
