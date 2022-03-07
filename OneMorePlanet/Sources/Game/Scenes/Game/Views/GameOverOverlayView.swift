import UIKit

final class GameOverOverlayView: UIView {
    // MARK: Properties

    private let score: Int
    private let bestScore: Int

    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.GameOver.MenuButton.title, for: .normal)
        button.titleLabel?.font = Fonts.AldoTheApache.regular.font(size: LayoutMetrics.menuButtonFontSize)
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title2)
        let icon = UIImage(systemName: Strings.GameOver.MenuButton.icon,
                           withConfiguration: symbolConfiguration)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(popToRootViewController), for: .touchUpInside)

        return button
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "SCORE: \(score)"
        label.font = Fonts.AldoTheApache.regular.font(size: LayoutMetrics.scoreLabelsFontSize)
        label.textColor = .white
        return label
    }()

    private lazy var bestScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "BEST: \(bestScore)"
        label.font = Fonts.AldoTheApache.regular.font(size: LayoutMetrics.scoreLabelsFontSize)
        label.textColor = .white
        return label
    }()

    private(set) lazy var extraLifeButton: CapsuleButton = {
        let button = CapsuleButton(title: Strings.GameOver.ExtraLifeButton.title,
                                   iconSystemName: Strings.GameOver.ExtraLifeButton.icon)
        return button
    }()

    private(set) lazy var playAgainButton: CapsuleButton = {
        let button = CapsuleButton(title: Strings.GameOver.PlayAgainButton.title,
                                   iconSystemName: Strings.GameOver.PlayAgainButton.icon)
        return button
    }()

    private(set) lazy var leaderboardButton: CapsuleButton = {
        let button = CapsuleButton(title: Strings.GameOver.LeaderboardButton.title,
                                   iconSystemName: Strings.GameOver.LeaderboardButton.icon)
        return button
    }()

    // MARK: Initialization

    init(score: Int, bestScore: Int) {
        self.score = score
        self.bestScore = bestScore
        super.init(frame: .zero)

        setupView()
        addSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Convenience

    private func setupView() {
        backgroundColor = UIColor(red: 13 / 255, green: 3 / 255, blue: 49 / 255, alpha: 1)
        layer.cornerRadius = LayoutMetrics.cornerRadius
    }

    private func addSubviews() {
        setupMenuButton()
        setupScoreLabel()
        setupBestScoreLabel()
        setupLeaderboardButton()
        setupPlayAgainButton()
        setupExtraLifeButton()
    }

    private func setupMenuButton() {
        addSubview(menuButton)

        menuButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(LayoutMetrics.menuButtonOffset)
            make.height.equalTo(LayoutMetrics.menuButtonFontSize)
        }
    }

    private func setupScoreLabel() {
        addSubview(scoreLabel)

        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(menuButton.snp.bottom).offset(LayoutMetrics.spacingBetweenDifferentElements)
            make.height.equalTo(LayoutMetrics.scoreLabelsFontSize)
            make.centerX.equalToSuperview()
        }
    }

    private func setupBestScoreLabel() {
        addSubview(bestScoreLabel)

        bestScoreLabel.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(LayoutMetrics.scoreLabelsVerticalSpacing)
            make.centerX.equalToSuperview()
        }
    }

    private func setupExtraLifeButton() {
        addSubview(extraLifeButton)

        extraLifeButton.snp.makeConstraints { make in
            make.topMargin.equalTo(bestScoreLabel.snp.bottom).offset(LayoutMetrics.spacingBetweenDifferentElements)
            make.width.equalToSuperview().multipliedBy(LayoutMetrics.roundedButtonWidthToSuperviewRatio)
            make.height.equalToSuperview().multipliedBy(LayoutMetrics.roundedButtonHeightToSuperviewRatio)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(playAgainButton.snp.top).offset(-LayoutMetrics.roundedButtonVerticalSpacing)
        }
    }

    private func setupPlayAgainButton() {
        addSubview(playAgainButton)

        playAgainButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(LayoutMetrics.roundedButtonWidthToSuperviewRatio)
            make.height.equalToSuperview().multipliedBy(LayoutMetrics.roundedButtonHeightToSuperviewRatio)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(leaderboardButton.snp.top).offset(-LayoutMetrics.roundedButtonVerticalSpacing)
        }
    }

    private func setupLeaderboardButton() {
        addSubview(leaderboardButton)

        leaderboardButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(LayoutMetrics.roundedButtonWidthToSuperviewRatio)
            make.height.equalToSuperview().multipliedBy(LayoutMetrics.roundedButtonHeightToSuperviewRatio)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-LayoutMetrics.spacingBetweenDifferentElements)
        }
    }

    @objc private func popToRootViewController() {
        findViewController()?.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Layout Metrics

    private enum LayoutMetrics {
        static let cornerRadius: CGFloat = 30
        static let menuButtonFontSize: CGFloat = 25
        static let menuButtonOffset: CGFloat = 20
        static let scoreLabelsVerticalSpacing: CGFloat = 20
        static let scoreLabelsFontSize: CGFloat = 35
        static let spacingBetweenDifferentElements: CGFloat = 50
        static let roundedButtonVerticalSpacing: CGFloat = 20
        static let roundedButtonWidthToSuperviewRatio: CGFloat = 0.7
        static let roundedButtonHeightToSuperviewRatio: CGFloat = 0.1
    }
}
