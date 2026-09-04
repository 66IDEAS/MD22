# Dependency and Release Supply Chain

- All JavaScript renderer packages use exact versions in `package.json` and a
  committed npm lockfile. Swift packages resolve through a committed
  `Package.resolved` file.
- Dependabot proposes version changes. Every update must pass renderer fixtures,
  unit tests, UI smoke tests, license review, and a production dependency audit.
- Production dependencies must permit redistribution and must not have unresolved
  high or critical vulnerabilities. Exceptions require a documented maintainer
  decision and mitigation.
- CI generates CycloneDX dependency data, SHA-256 checksums, and build provenance.
  Release tags and attached binaries are immutable; a correction receives a new
  version.
- Signing, notarization, and Sparkle private keys are protected repository secrets
  and never committed. Release artifacts are signed before publication.

