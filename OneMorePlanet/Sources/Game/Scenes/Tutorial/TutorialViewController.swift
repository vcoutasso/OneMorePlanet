import UIKit

class TutorialViewController: UIViewController {
    private lazy var titleStackView: UIStackView = {
        let title = UILabel()
        title.text = "HOW TO PLAY"
        title.font = UIFont(name: Fonts.AldoTheApache.regular.name, size: 35)
        title.textColor = UIColor.white
        title.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [title])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .top
        stack.spacing = LayoutMetrics.titleStackViewSpacing

        return stack
    }()

    private lazy var tutorial1: UIStackView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.tutorial1))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 15)
        label.text = "TAP NEAR THE PLANETS TO ACTIVATE\n THEIR GRAVITATIONAL FIELDS"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        let attributedString =
            NSMutableAttributedString(string: "TAP NEAR THE PLANETS TO ACTIVATE\n THEIR GRAVITATIONAL FIELDS")
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                      range: NSMakeRange(0, attributedString.length))

        label.attributedText = attributedString
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [
            imageView,
            label,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fillProportionally
        stack.contentMode = .scaleAspectFit
        stack.layer.borderWidth = 1
        stack.layer.cornerRadius = 30
        stack.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 100)
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
        stack.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: imageView.widthAnchor),
        ])

        return stack
    }()

    private lazy var tutorial2: UIStackView = {
        let imageView = UIImageView(image: UIImage(asset: Assets.Images.tutorial2))
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.font = UIFont(font: Fonts.AldoTheApache.regular, size: 15)
        label.text = "DON'T HIT THE PLANETS OR\n ASTEROIDS DIRECTLY"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        let attributedString = NSMutableAttributedString(string: "DON'T HIT THE PLANETS OR\n ASTEROIDS DIRECTLY")
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                      range: NSMakeRange(0, attributedString.length))

        label.attributedText = attributedString
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [
            imageView,
            label,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fillProportionally
        stack.contentMode = .scaleAspectFit
        stack.layer.borderWidth = 1
        stack.layer.cornerRadius = 30
        stack.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 100)
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 5, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: imageView.widthAnchor),
        ])

        return stack
    }()

    private lazy var checkButton: UIButton = {
        let symbol = UIImage(systemName: "checkmark.circle.fill")
        let button = UIButton()
        button.setImage(symbol, for: .normal)
        let configuration = UIImage.SymbolConfiguration(pointSize: 38.0, weight: .medium)
        button.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(asset: Assets.Colors.buttonBackground)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupHierarchy()
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            titleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            tutorial1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorial1.topAnchor.constraint(equalTo: titleStackView.bottomAnchor,
                                           constant: 30),

            tutorial2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorial2.topAnchor.constraint(equalTo: tutorial1.bottomAnchor,
                                           constant: LayoutMetrics.distanceBetweenImages),

            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -30),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupViews() {
        view.backgroundColor = UIColor(asset: Assets.Colors.spaceBackground)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }

    private func setupHierarchy() {
        view.addSubview(tutorial1)
        view.addSubview(tutorial2)
        view.addSubview(titleStackView)
        view.addSubview(checkButton)
    }

    private enum LayoutMetrics {
        static let titleFontSize: CGFloat = 35
        static let titleStackViewSpacing: CGFloat = 30
        static let distanceBetweenImages: CGFloat = 30
    }

    @objc private func checkButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
