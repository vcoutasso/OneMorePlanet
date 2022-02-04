import SpriteKit

struct ColliderType: OptionSet, Hashable {
    // MARK: Static properties

    static let requestedContactNotifications: [ColliderType: [ColliderType]] = {
        var notifications = [ColliderType: [ColliderType]]()
        notifications[.Player] = [.Obstacle]

        return notifications
    }()
    static let definedCollisions: [ColliderType: [ColliderType]] = {
        var collisions = [ColliderType: [ColliderType]]()
        collisions[.Player] = [.Obstacle]

        return collisions
    }()

    // MARK: Properties

    let rawValue: UInt32

    static var Obstacle: ColliderType { return self.init(rawValue: 0x01 << 0) }
    static var Player: ColliderType { return self.init(rawValue: 0x01 << 1) }

    var categoryMask: UInt32 {
        return rawValue
    }

    var collisionMask: UInt32 {
        let mask = ColliderType.definedCollisions[self]?.reduce(ColliderType()) { initial, colliderType in
            initial.union(colliderType)
        }

        return mask?.rawValue ?? 0
    }

    var contactMask: UInt32 {
        let mask = ColliderType.requestedContactNotifications[self]?.reduce(ColliderType()) { initial, colliderType in
            initial.union(colliderType)
        }

        return mask?.rawValue ?? 0
    }

    func notifyOnContactWith(_ colliderType: ColliderType) -> Bool {
        if let requestedContacts = ColliderType.requestedContactNotifications[self] {
            return requestedContacts.contains(colliderType)
        }

        return false
    }
}
