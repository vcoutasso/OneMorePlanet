import UIKit

final class RoundButton: UIButton {
    // MARK: Properties

    private var iconSystemName: String
    private let style: ButtonStyle

    private lazy var backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = gradientLayer.frame.height / 2
        gradientLayer.colors = [
            Assets.Colors.buttonDarkBackgroundGradient.color.cgColor,
            Assets.Colors.buttonLightBackgroundGradient.color.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.3]
        layer.insertSublayer(gradientLayer, at: 0)

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

    init(iconSystemName: String, style: ButtonStyle) {
        self.iconSystemName = iconSystemName
        self.style = style

        super.init(frame: .zero)

        setButtonImage()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    func updateSymbol(with systemName: String) {
        iconSystemName = systemName
        setButtonImage()
    }

    // MARK: Convenience methods

    private func setButtonImage() {
        let symbolConfiguration: UIImage.SymbolConfiguration

        switch style {
        case .small:
            symbolConfiguration = UIImage.SymbolConfiguration(pointSize: LayoutMetrics.smallStyleSymbolPointSize,
                                                              weight: .medium)
        case .large:
            symbolConfiguration = UIImage.SymbolConfiguration(pointSize: LayoutMetrics.largeStyleSymbolPointSize,
                                                              weight: .medium)
        }

        let icon = UIImage(systemName: iconSystemName, withConfiguration: symbolConfiguration)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        setImage(icon, for: .normal)
    }

    // MARK: Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundGradientLayer.frame = bounds

        switch style {
        case .small:
            imageEdgeInsets = LayoutMetrics.smallEdgeInsets
        case .large:
            imageEdgeInsets = LayoutMetrics.largeEdgeInsets
        }
    }

    // MARK: Button Style

    enum ButtonStyle {
        case small
        case large
    }

    // MARK: - Layout Metrics

    private enum LayoutMetrics {
        static let smallStyleSymbolPointSize: CGFloat = 28.0
        static let largeStyleSymbolPointSize: CGFloat = 50.0
        private static let smallInset: CGFloat = 6
        private static let largeInset: CGFloat = 12
        static let smallEdgeInsets = UIEdgeInsets(top: smallInset, left: smallInset, bottom: smallInset,
                                                  right: smallInset)
        static let largeEdgeInsets = UIEdgeInsets(top: largeInset, left: largeInset, bottom: largeInset,
                                                  right: largeInset)
    }
}
