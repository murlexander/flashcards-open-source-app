import SwiftUI

struct AICompanionToolbarButton: View {
    @Environment(AppNavigationModel.self) private var navigation: AppNavigationModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if self.horizontalSizeClass == .regular || self.navigation.isAICompanionVisible {
            Button {
                self.navigation.isAICompanionPresented.toggle()
            } label: {
                Label(
                    String(localized: self.navigation.isAICompanionVisible
                           ? "ai_companion.hide" : "ai_companion.show", table: "Foundation"),
                    systemImage: "bubble.left.and.bubble.right"
                )
            }
            .accessibilityIdentifier(UITestIdentifier.aiCompanionToggle)
        }
    }
}
