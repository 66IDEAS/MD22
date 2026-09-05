import AppKit
import SwiftUI

struct BrandLogo: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if let image = image {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .accessibilityLabel("MD22")
        } else {
            Text("MD22")
                .font(.largeTitle.weight(.semibold))
        }
    }

    private var image: NSImage? {
        let name = colorScheme == .dark ? "md22-dark" : "md22-light"
        guard let url = Bundle.main.url(forResource: name, withExtension: "svg") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}
