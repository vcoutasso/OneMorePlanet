import CoreGraphics

extension SIMD2 where Scalar == Float {
    init(x: CGFloat, y: CGFloat) {
        self.init(x: Float(x),
                  y: Float(y))
    }
}
