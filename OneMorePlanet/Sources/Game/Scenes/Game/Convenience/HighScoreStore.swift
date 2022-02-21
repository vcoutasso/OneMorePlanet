import RealmSwift

final class HighScoreStore {
    // swiftlint:disable force_try

    // MARK: Initialization

    init() {
        if try! Realm().isEmpty {
            initializeRealm()
        }
    }

    // MARK: Public methods

    func fetchHighScore() -> Score {
        try! Realm().objects(Score.self).first!
    }

    func tryToUpdateHighScore(with newScore: Score) {
        let currentHigh = fetchHighScore()

        if newScore > currentHigh {
            try! Realm().write {
                currentHigh.value = newScore.value
            }
        }
    }

    // MARK: Setup

    private func initializeRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(Score.zero)
        }
    }
}
