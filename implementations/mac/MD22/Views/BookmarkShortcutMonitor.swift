import AppKit
import SwiftUI

/// Keeps Command-D bound to the active reader when WebKit owns keyboard focus.
@MainActor
struct BookmarkShortcutMonitor: NSViewRepresentable {
    let onAddBookmark: @MainActor () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onAddBookmark: onAddBookmark)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.view = view
        context.coordinator.start()
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.onAddBookmark = onAddBookmark
    }

    static func dismantleNSView(_ view: NSView, coordinator: Coordinator) {
        coordinator.stop()
    }

    @MainActor
    final class Coordinator {
        weak var view: NSView?
        var onAddBookmark: @MainActor () -> Void
        private var monitor: Any?

        init(onAddBookmark: @escaping @MainActor () -> Void) {
            self.onAddBookmark = onAddBookmark
        }

        func start() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, self.view?.window?.isKeyWindow == true else { return event }
                let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                guard modifiers == .command,
                      event.charactersIgnoringModifiers?.lowercased() == "d" else {
                    return event
                }
                self.onAddBookmark()
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
