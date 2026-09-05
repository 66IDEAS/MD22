import Foundation

enum MarkdownAnalysis {
    /// Runs analysis away from actor executors and propagates cancellation to obsolete work.
    static func analyzeAsync(_ markdown: String) async throws -> DocumentAnalysis {
        let work = Task.detached(priority: .userInitiated) {
            try Task.checkCancellation()
            let result = analyze(markdown)
            try Task.checkCancellation()
            return result
        }
        return try await withTaskCancellationHandler {
            try await work.value
        } onCancel: {
            work.cancel()
        }
    }

    static func analyze(_ markdown: String) -> DocumentAnalysis {
        var headings: [Heading] = []
        var slugCounts: [String: Int] = [:]
        var insideFence = false

        for line in markdown.split(separator: "\n", omittingEmptySubsequences: false) {
            let text = String(line)
            let trimmed = text.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("```") || trimmed.hasPrefix("~~~") {
                insideFence.toggle()
                continue
            }
            guard !insideFence, let match = heading(in: text) else { continue }
            let baseSlug = slug(for: match.title)
            let occurrence = slugCounts[baseSlug, default: 0]
            slugCounts[baseSlug] = occurrence + 1
            let identifier = occurrence == 0 ? baseSlug : "\(baseSlug)-\(occurrence)"
            headings.append(Heading(id: identifier, level: match.level, title: match.title))
        }

        let words = markdown
            .replacingOccurrences(of: #"```[\s\S]*?```"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"<[^>]+>|[#*_`>\[\]()!|~-]"#, with: " ", options: .regularExpression)
            .split(whereSeparator: { $0.isWhitespace })
            .count
        return DocumentAnalysis(
            headings: headings,
            wordCount: words,
            estimatedReadingMinutes: max(1, Int(ceil(Double(words) / 220.0)))
        )
    }

    static func slug(for title: String) -> String {
        let folded = title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let allowed = folded.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(String(scalar)) : "-"
        }
        let collapsed = String(allowed)
            .replacingOccurrences(of: #"-+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return collapsed.isEmpty ? "section" : collapsed
    }

    private static func heading(in line: String) -> (level: Int, title: String)? {
        let pattern = #"^\s{0,3}(#{1,6})\s+(.+?)\s*#*\s*$"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let marksRange = Range(match.range(at: 1), in: line),
              let titleRange = Range(match.range(at: 2), in: line) else { return nil }
        return (line[marksRange].count, String(line[titleRange]))
    }
}
