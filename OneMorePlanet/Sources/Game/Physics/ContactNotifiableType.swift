import GameplayKit

protocol ContactNotifiableType {
    func contactWithEntityDidBegin( _ entity: GKEntity)
    func contactWithEntityDidEnd( _ entity: GKEntity)
}
