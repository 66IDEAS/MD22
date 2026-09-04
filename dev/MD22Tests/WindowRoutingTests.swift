import Foundation
import Testing
@testable import MD22

@Suite("Window routing")
struct WindowRoutingTests {
    @Test("Typed new-window requests preserve bookmark destinations")
    func requestRoundTrip() throws {
        let location = ReadingLocation(headingID: "details", progress: 0.42, verticalOffset: 812)
        let route = DocumentRoute(
            url: URL(fileURLWithPath: "/tmp/guide.md"),
            source: .bookmark,
            disposition: .newWindow,
            bookmarkID: UUID(),
            headingID: "details",
            location: location
        )
        let request = DocumentWindowRequest(route: route)

        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(DocumentWindowRequest.self, from: data)

        #expect(decoded == request)
        #expect(decoded.url.path == "/tmp/guide.md")
        #expect(decoded.location == location)
        #expect(decoded.headingID == "details")
    }
}
