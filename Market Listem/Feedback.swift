#if canImport(UIKit)
import UIKit

@MainActor
enum Feedback {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
#else
enum Feedback {
    static func success() {}
    static func selection() {}
}
#endif
