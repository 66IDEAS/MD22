# Contributing to MD22

Contributions are welcome. Discuss substantial product changes before starting
implementation and keep pull requests focused on one coherent change.

## Development rules

1. Preserve the read-only guarantee for source Markdown.
2. Keep document processing local and do not add telemetry or accounts.
3. Keep rendering dependencies pinned and bundled.
4. Add tests for behavior changes and run the complete command-line test suite.
5. Use native macOS conventions and validate keyboard and VoiceOver behavior.
6. Update third-party notices when dependencies change.

Use Xcode command-line tools for reproducible builds. The generated Xcode
project is intentionally ignored; edit `implementations/mac/project.yml` and
regenerate it.
