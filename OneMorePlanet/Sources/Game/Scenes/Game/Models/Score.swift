import RealmSwift

final class Score: Object {
    // MARK: Static variables

    static let zero = Score(value: 0)

    // MARK: Properties

    @Persisted var value: Int

    // MARK: Initialization

    override init() {
        super.init()
        self.value = 0
    }

    init(value: Int) {
        super.init()
        self.value = value
    }
}

extension Score: Comparable {
    static func < (lhs: Score, rhs: Score) -> Bool {
        lhs.value < rhs.value
    }
}
