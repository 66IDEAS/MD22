import SwiftUI

struct LiquidGlassCard: ViewModifier {
    var interactive = false

    func body(content: Content) -> some View {
        content
            .padding(24)
            .glassEffect(
                interactive ? .regular.interactive() : .regular,
                in: .rect(cornerRadius: 22, style: .continuous)
            )
    }
}

extension View {
    func liquidGlassCard(interactive: Bool = false) -> some View {
        modifier(LiquidGlassCard(interactive: interactive))
    }
}

struct GlassIconButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.glass)
        .help(title)
    }
}

