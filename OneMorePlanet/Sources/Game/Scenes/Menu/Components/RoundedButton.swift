import UIKit

final class RoundedButton: UIButton {
    var titleText: String? {
        didSet {
            setTitle(titleText, for: .normal)
            titleLabel?.font = UIFont(name: Fonts.AldoTheApache.regular.name, size: LayoutMetrics.buttonTitleFontSize)
        }
    }

    var backgroundColorName: String? {
        didSet {
            backgroundColor = UIColor(asset: Assets.Colors.buttonBackground)
        }
    }

    var titleColorName: String? {
        didSet {
            setTitleColor(UIColor.white, for: .normal)
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false

        layer.zPosition = 1
        layer.cornerRadius = LayoutMetrics.buttonCornerRadius
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func createPurpleButton(title: String) -> RoundedButton {
        let purpleButton = RoundedButton()

        purpleButton.titleText = title
        purpleButton.backgroundColorName = "buttonBackground"
        purpleButton.titleColorName = "white"

        return purpleButton
    }

    enum LayoutMetrics {
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = buttonHeight / 2
        static let buttonTitleFontSize: CGFloat = 30
        static let buttonHorizontalPadding: CGFloat = 70
        static let buttonVerticalPadding: CGFloat = -60
    }
}
