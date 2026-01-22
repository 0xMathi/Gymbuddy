import UIKit

class HapticService {
    static let shared = HapticService()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    
    func light() {
        impactLight.impactOccurred()
    }
    
    func medium() {
        impactMedium.impactOccurred()
    }
    
    func heavy() {
        impactHeavy.impactOccurred()
    }
    
    func success() {
        notification.notificationOccurred(.success)
    }
    
    func warning() {
        notification.notificationOccurred(.warning)
    }
    
    func error() {
        notification.notificationOccurred(.error)
    }
}
