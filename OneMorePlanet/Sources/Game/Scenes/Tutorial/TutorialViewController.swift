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

    private lazy var tutorial1: UIImageView = {
        let image = UIImage(asset: Assets.Images.tutorial1)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var tutorial2: UIImageView = {
        let image = UIImage(asset: Assets.Images.tutorial2)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = checkButton.bounds
        gradientLayer.colors = [
            Assets.Colors.buttonDarkBackgroundGradient.color.cgColor,
            Assets.Colors.buttonLightBackgroundGradient.color.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.7, 1.0]

        return gradientLayer
    }()

    private lazy var checkButton: RoundButton = {
        let button = RoundButton(iconSystemName: Strings.Tutorial.CheckmarkButton.icon,
                                 style: .large)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupHierarchy()
        setupConstraints()
    }

    private func setupConstraints() {
        titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.topMargin.equalToSuperview().offset(40)
        }

        tutorial1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(50)
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        tutorial2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tutorial1.snp.bottom).offset(50)
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        checkButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-35)
        }
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
        navigationController!.popViewController(animated: true)
    }
}
