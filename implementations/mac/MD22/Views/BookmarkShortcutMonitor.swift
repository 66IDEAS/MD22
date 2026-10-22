import AppKit
import SwiftUI

/// Keeps reader shortcuts bound to the active window when WebKit owns keyboard focus.
@MainActor
struct BookmarkShortcutMonitor: NSViewRepresentable {
    let onAddBookmark: @MainActor () -> Void
    let onFind: @MainActor () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onAddBookmark: onAddBookmark, onFind: onFind)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.view = view
        context.coordinator.start()
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.onAddBookmark = onAddBookmark
        context.coordinator.onFind = onFind
    }

    static func dismantleNSView(_ view: NSView, coordinator: Coordinator) {
        coordinator.stop()
    }

    @MainActor
    final class Coordinator {
        weak var view: NSView?
        var onAddBookmark: @MainActor () -> Void
        var onFind: @MainActor () -> Void
        private var monitor: Any?

        init(
            onAddBookmark: @escaping @MainActor () -> Void,
            onFind: @escaping @MainActor () -> Void
        ) {
            self.onAddBookmark = onAddBookmark
            self.onFind = onFind
        }

        func start() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, self.view?.window?.isKeyWindow == true else { return event }
                let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                guard modifiers == .command else {
                    return event
                }
                switch event.charactersIgnoringModifiers?.lowercased() {
                case "d": self.onAddBookmark()
                case "f": self.onFind()
                default: return event
                }
                return nil
            }
        }

        func stop() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }
    }
}
