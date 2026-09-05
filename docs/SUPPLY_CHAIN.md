# Dependency and Release Supply Chain

## Dependency policy

All JavaScript renderer packages use exact versions in `package.json` and a
committed npm lockfile. Swift packages resolve through the committed root
`implementations/mac/Package.resolved`; project generation copies that resolution into Xcode's
workspace metadata before every build.

`npm run audit:dependencies` rejects packages without a reviewed,
redistribution-compatible license, lock records without version and integrity
data, unexpected Swift packages, and high or critical npm advisories. The only
metadata override is tied to the exact `khroma` 2.1.0 package, whose distributed
license file is MIT even though its package metadata omits the license field.
A version change invalidates that review.

Dependabot monitors npm, SwiftPM, and GitHub Actions weekly. The pull-request
dependency-review job independently rejects new high-severity advisories and
licenses outside the approved policy. Third-party Actions are pinned by complete
commit SHA and must be updated through reviewed pull requests.

## Continuous integration

`.github/workflows/ci.yml` runs on pull requests and the protected `main` branch.
The Apple-silicon macOS 26 job verifies the Xcode and SDK generation, audits
dependencies, reproduces the bundled renderer, runs native unit and UI tests,
builds Release without credentials, and verifies the resulting architecture.
Pull-request workflows receive read-only repository access and never receive
release credentials.

Configure `main` as a protected branch that requires both `Dependency review`
and `Build and test on macOS 26` before merge. Require pull requests, dismiss
stale approvals when new commits are pushed, require conversation resolution,
and disallow force pushes and deletion.

## Release integrity

`.github/workflows/release.yml` accepts an exact `vMAJOR.MINOR.PATCH` tag only
when its commit is reachable from `main`. The unprivileged verification job
runs the complete CI suite before the protected `release` environment can expose
credentials. The publication job then:

1. builds and signs every application component with Developer ID and Hardened
   Runtime;
2. notarizes and staples the app and Apple-silicon DMG;
3. creates the resource-preserving Sparkle archive and EdDSA-signed appcast;
4. emits an SPDX 2.3 SBOM and SHA-256 checksums;
5. creates GitHub SLSA build-provenance and SBOM attestations; and
6. uploads every asset to a draft release before publishing and verifying the
   immutable release and each local asset.

Enable **Settings → General → Releases → Enable release immutability** before
the first release. The workflow queries GitHub's immutable-release endpoint and
fails closed if the feature is disabled or a release already exists for the tag.
A correction always receives a new version; published tags and assets are never
replaced.

Signing certificates, notarization keys, and the Sparkle private key exist only
as protected environment secrets. Ephemeral keychain and key files are deleted
after every release attempt. A separate fine-grained token with Administration
read access performs only the immutability preflight because GitHub's ordinary
workflow token cannot query that setting. Publication continues to use the
short-lived workflow token. The repository contains only Sparkle's public key.
