import SwiftUI

extension AIChatView {
    /// Inspector toolbars share the host navigation bar. Keep companion tools
    /// inside their pane so they cannot replace Cards or Review's title/actions.
    var companionHeader: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    if self.horizontalSizeClass == .regular && self.navigation.isAICompanionLeadingAvailable {
                        Button {
                            withAnimation(self.reduceMotion ? nil : .smooth(duration: 0.35)) {
                                self.navigation.isAICompanionLeading.toggle()
                            }
                        } label: {
                            Label(
                                String(localized: self.navigation.isAICompanionLeading
                                    ? "ai_companion.move_right" : "ai_companion.move_left", table: "Foundation"),
                                systemImage: self.navigation.isAICompanionLeading ? "arrow.right" : "arrow.left"
                            )
                        }
                        .accessibilityIdentifier(UITestIdentifier.aiCompanionMove)
                    }
                }

                Text(aiSettingsLocalized("ai.title", "AI"))
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                if self.accessState == .ready {
                    Button {
                        self.chatStore.clearHistory()
                    } label: {
                        Label(aiSettingsLocalized("ai.newChat", "New"), systemImage: "square.and.pencil")
                    }
                    .accessibilityIdentifier(UITestIdentifier.aiNewChatButton)
                    .disabled(self.isNewChatDisabled || self.chatStore.isChatInteractive == false)
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .disabled(self.isPresentationActive == false)
    }
}
