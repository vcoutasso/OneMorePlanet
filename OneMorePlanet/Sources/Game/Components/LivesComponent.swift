import GameplayKit

final class LivesComponent: GKComponent {
    // MARK: Properties

    private(set) var maximumLives: Int
    private(set) var numberOfLives: Int

    var isAlive: Bool {
        numberOfLives > 0
    }

    // MARK: Initialization

    init(maximumLives: Int) {
        self.maximumLives = maximumLives
        self.numberOfLives = maximumLives

        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods

    func takeLife() {
        takeLifes(1)
    }

    func awardLifes(_ qty: Int) {
        numberOfLives += qty
    }

    private func takeLifes(_ qty: Int) {
        numberOfLives -= qty
    }
}
