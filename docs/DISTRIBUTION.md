# Direct Distribution

MD22 is distributed outside the Mac App Store as a Developer ID-signed,
Hardened Runtime-enabled, notarized Apple-silicon application. App Sandbox is
deliberately disabled so an explicitly opened Markdown file can resolve sibling
project resources and receive adjacent HTML or PDF exports.

## Prerequisites

- macOS 26 and Xcode 26 command-line tools
- XcodeGen and Node.js
- A `Developer ID Application` certificate in the signing keychain
- Notary service credentials stored by `notarytool`, or an App Store Connect API
  key available as a protected file

Do not place certificates, private keys, passwords, or API keys in the repository.

## Create the signed archive

Set the exact certificate name shown by `security find-identity -v -p
codesigning`, the Apple Developer team ID, and the version identifiers:

```sh
export MD22_SIGNING_IDENTITY='Developer ID Application: Example (TEAMID)'
export MD22_TEAM_ID='TEAMID'
export MD22_VERSION='1.0.0'
export MD22_BUILD_NUMBER='1'
dev/scripts/archive-release.zsh
```

The command rebuilds the pinned renderer, regenerates the Xcode project,
archives for generic Apple-silicon macOS, and validates the signature,
Hardened Runtime, minimum OS, architecture, and absence of App Sandbox.

## Notarize and package

For a local release, first store credentials in the Keychain with Apple's
`notarytool store-credentials` command, then run:

```sh
export MD22_NOTARY_KEYCHAIN_PROFILE='MD22-notary'
dev/scripts/notarize-release.zsh \
  dev/build/release/MD22-1.0.0-1/MD22.app
```

For CI, provide `MD22_NOTARY_KEY_PATH`, `MD22_NOTARY_KEY_ID`, and, for a team
API key, `MD22_NOTARY_ISSUER_ID` instead of a Keychain profile. The script:

1. verifies the archived app and submits a resource-preserving ZIP to Apple;
2. staples and validates the accepted app ticket;
3. creates and signs a DMG containing the app, Applications link, license, and
   third-party notices;
4. notarizes, staples, and Gatekeeper-assesses the DMG; and
5. emits the notarized Sparkle ZIP and `SHA256SUMS` beside the DMG.

Release artifacts are never overwritten. A corrected release must use a new
version or build number.

## Manual release checks

Before publication, install the app from the DMG on a clean macOS 26 system,
open a Markdown file from Finder, confirm project-relative images and links,
export adjacent HTML and PDF files, exercise VoiceOver and all keyboard
commands, and check automatic plus manual update discovery against a staged
signed appcast.

## Automated GitHub release

Create a protected GitHub environment named `release`. Limit deployment to
protected version tags, require a maintainer approval, prevent self-review, and
store these environment secrets:

- `MD22_DEVELOPER_ID_CERTIFICATE_BASE64`: base64 of the exported Developer ID
  Application certificate and private key in PKCS #12 format
- `MD22_DEVELOPER_ID_CERTIFICATE_PASSWORD`: password for that PKCS #12 file
- `MD22_SIGNING_IDENTITY`: complete Keychain identity, including team suffix
- `MD22_TEAM_ID`: Apple Developer team identifier
- `MD22_NOTARY_KEY_BASE64`: base64 of the App Store Connect API `.p8` key
- `MD22_NOTARY_KEY_ID`: API key identifier
- `MD22_NOTARY_ISSUER_ID`: App Store Connect issuer identifier
- `MD22_SPARKLE_PRIVATE_KEY_BASE64`: base64 of the private EdDSA key file that
  matches the public key in the application Info.plist
- `MD22_RELEASE_ADMIN_READ_TOKEN`: fine-grained repository token scoped only
  to MD22 with Administration read permission, used to fail closed unless
  release immutability is enabled

Secrets must be base64-encoded as files, not copied as unencoded multiline
values. Do not make them repository-level secrets: the `release` environment is
the security boundary that keeps them out of verification and pull-request jobs.

Enable GitHub release immutability and the protected `main` branch as described
in [Dependency and Release Supply Chain](SUPPLY_CHAIN.md). After CI succeeds,
create and push a version tag whose commit is on `main`:

```sh
git tag -a v1.0.0 -m 'MD22 1.0.0'
git push origin v1.0.0
```

The release workflow uses its run number as `CFBundleVersion`, publishes the
DMG, Sparkle ZIP, signed `appcast.xml`, SPDX SBOM, and checksums together, and
attests them through GitHub's artifact-attestation service. It refuses an
existing release and verifies immutability plus every uploaded asset after
publication.
