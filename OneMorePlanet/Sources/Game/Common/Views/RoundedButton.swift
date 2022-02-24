import UIKit

final class RoundedButton: UIButton {
    // MARK: Properties

    private lazy var backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = LayoutMetrics.buttonCornerRadius
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            Assets.Colors.buttonDarkBackgroundGradient.color.cgColor,
            Assets.Colors.buttonLightBackgroundGradient.color.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.7, 1.0]

        return gradientLayer
    }()

    override var isHighlighted: Bool {
        didSet {
            let xScale: CGFloat = isHighlighted ? 1.025 : 1.0
            let yScale: CGFloat = isHighlighted ? 1.05 : 1.0

            UIView.animate(withDuration: 0.1) {
                let transformation = CGAffineTransform(scaleX: xScale, y: yScale)
                self.transform = transformation
            }
        }
    }

    // MARK: Initialization

    init(title: String, iconSystemName: String) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Fonts.AldoTheApache.regular.font(size: LayoutMetrics.buttonTitleFontSize)

        let symbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let icon = UIImage(systemName: iconSystemName, withConfiguration: symbolConfiguration)?.withTintColor(.white,
                                                                                                              renderingMode: .alwaysOriginal)
        setImage(icon, for: .normal)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.insertSublayer(backgroundGradientLayer, at: 0)

        guard let imageView = imageView else { return }

        imageEdgeInsets = UIEdgeInsets(top: 0, left: bounds.width - LayoutMetrics.imageTrailingOffset, bottom: 0,
                                       right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageView.frame.width)
    }

    // MARK: - Layout Metrics

    private enum LayoutMetrics {
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = buttonHeight / 2
        static let buttonTitleFontSize: CGFloat = 22
        static let buttonHorizontalPadding: CGFloat = 70
        static let buttonVerticalPadding: CGFloat = -60
        static let imageTrailingOffset: CGFloat = 40
    }
}
