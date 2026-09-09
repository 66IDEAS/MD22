# Contributing to MD22

Contributions are welcome to the product specifications, documentation, and
implementations. Please keep each issue or pull request focused on one topic.

## Report a bug

Open a [GitHub issue](https://github.com/66IDEAS/MD22/issues). Include:

- The application version/build, macOS version, and Mac architecture
- Steps to reproduce, expected behavior, and actual behavior
- A small, non-sensitive Markdown example when rendering or export is involved
- A screenshot or relevant error message, with private information removed

Check existing issues and the [bug tracker](specs/bugs.md) first. Do not upload
private project documents, access tokens, signing credentials, or unredacted logs.

## Propose a product change

Read the [functional specification](specs/specifications.md) and
[UX specification](specs/ux.md). Explain the use case, affected requirements,
and proposed acceptance criteria in an issue or focused specification PR.
Discuss substantial changes before investing in a large implementation.

Respect the Version 1/Phase 2 boundary. Editing Markdown is outside Version 1;
the source file must remain unchanged by reading, navigation, and export.

## Change the Mac implementation

Follow the [macOS implementation guide](implementations/mac/README.md) to build
and test. In your pull request:

- Link the issue or relevant specification section.
- Describe what changed and why.
- Include regression coverage and state exactly which checks you ran.
- Add screenshots for visible interface changes; inspect generated HTML/PDF
  output when changing exports.
- Update relevant documentation and specifications when behavior changes.
- Keep generated renderer assets in sync with their sources and preserve locks.

Document checks you could not run instead of claiming they passed. Do not commit
application bundles, build caches, private documents, or credentials.

## Add another implementation

Use `implementations/<name>/` without replacing an existing implementation.
Start from the functional and UX specifications, and propose the platform and
scope in an issue before a substantial contribution.

Include a README with prerequisites, build/run/test instructions, supported
features, limitations, and known divergences. Document platform-specific
architecture separately: the existing architecture includes macOS-specific
decisions and is not a universal technology prescription.

## License

MD22 is [MIT-licensed](LICENSE). Contribute only material you have the right to
share under that license. Preserve copyright notices and document the licenses
of any third-party code, fonts, images, or dependencies you add.
