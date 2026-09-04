#!/usr/bin/env node

import { readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { createHash } from "node:crypto";
import path from "node:path";
import process from "node:process";

const scriptsDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectDirectory = path.dirname(scriptsDirectory);
const [outputArgument, versionArgument] = process.argv.slice(2);

if (!outputArgument || !versionArgument) {
  console.error("usage: node scripts/generate-sbom.mjs <output.json> <application-version>");
  process.exit(64);
}

const lockfile = JSON.parse(
  await readFile(path.join(projectDirectory, "package-lock.json"), "utf8"),
);
const swiftResolution = JSON.parse(
  await readFile(path.join(projectDirectory, "Package.resolved"), "utf8"),
);

const repository = process.env.GITHUB_REPOSITORY ?? "alexanderilg/MD22";
const revision = process.env.GITHUB_SHA ?? "source";
const timestamp = process.env.SOURCE_DATE_EPOCH
  ? new Date(Number(process.env.SOURCE_DATE_EPOCH) * 1000).toISOString()
  : new Date().toISOString();
const applicationRef = "SPDXRef-Package-MD22";
const reviewedMissingLicenseMetadata = new Map([
  ["node_modules/khroma@2.1.0", "MIT"],
]);

function packageName(packagePath) {
  const marker = "node_modules/";
  const location = packagePath.lastIndexOf(marker);
  return location === -1 ? packagePath : packagePath.slice(location + marker.length);
}

function npmPurl(name, version) {
  const encodedName = name.startsWith("@")
    ? `${encodeURIComponent(name.split("/")[0])}/${encodeURIComponent(name.split("/")[1])}`
    : encodeURIComponent(name);
  return `pkg:npm/${encodedName}@${encodeURIComponent(version)}`;
}

function licenseExpression(license) {
  return license ?? "NOASSERTION";
}

const components = [];
const dependencyRefs = [];

let packageIndex = 0;
for (const [packagePath, metadata] of Object.entries(lockfile.packages ?? {})) {
  if (packagePath === "" || !metadata.version) {
    continue;
  }
  const name = packageName(packagePath);
  const purl = npmPurl(name, metadata.version);
  const declaredLicense = metadata.license
    ?? reviewedMissingLicenseMetadata.get(`${packagePath}@${metadata.version}`);
  const spdxID = `SPDXRef-Package-npm-${packageIndex}`;
  packageIndex += 1;
  dependencyRefs.push(spdxID);
  components.push({
    SPDXID: spdxID,
    name,
    versionInfo: metadata.version,
    downloadLocation: metadata.resolved ?? "NOASSERTION",
    filesAnalyzed: false,
    licenseConcluded: licenseExpression(declaredLicense),
    licenseDeclared: licenseExpression(declaredLicense),
    copyrightText: "NOASSERTION",
    externalRefs: [
      {
        referenceCategory: "PACKAGE-MANAGER",
        referenceType: "purl",
        referenceLocator: purl,
      },
    ],
    comment: `npm lockfile path: ${packagePath}`,
  });
}

for (const pin of swiftResolution.pins ?? []) {
  const version = pin.state?.version ?? pin.state?.revision ?? "unknown";
  const purl = `pkg:swift/${encodeURIComponent(pin.identity)}@${encodeURIComponent(version)}`;
  const spdxID = `SPDXRef-Package-swift-${packageIndex}`;
  packageIndex += 1;
  dependencyRefs.push(spdxID);
  components.push({
    SPDXID: spdxID,
    name: pin.identity,
    versionInfo: version,
    downloadLocation: pin.location ?? "NOASSERTION",
    filesAnalyzed: false,
    licenseConcluded: pin.identity === "sparkle" ? "MIT" : "NOASSERTION",
    licenseDeclared: pin.identity === "sparkle" ? "MIT" : "NOASSERTION",
    copyrightText: "NOASSERTION",
    externalRefs: [
      {
        referenceCategory: "PACKAGE-MANAGER",
        referenceType: "purl",
        referenceLocator: purl,
      },
    ],
    comment: `SwiftPM revision: ${pin.state?.revision ?? "unknown"}`,
  });
}

components.sort((left, right) => left.SPDXID.localeCompare(right.SPDXID));
dependencyRefs.sort();

const revisionHash = createHash("sha256").update(revision).digest("hex");

const sbom = {
  spdxVersion: "SPDX-2.3",
  dataLicense: "CC0-1.0",
  SPDXID: "SPDXRef-DOCUMENT",
  name: `MD22-${versionArgument}`,
  documentNamespace: `https://github.com/${repository}/releases/download/v${encodeURIComponent(versionArgument)}/sbom-${revisionHash}`,
  creationInfo: {
    created: timestamp,
    creators: ["Tool: MD22-SBOM-Generator-1"],
    licenseListVersion: "3.27.0",
  },
  documentDescribes: [applicationRef],
  packages: [
    {
      SPDXID: applicationRef,
      name: "MD22",
      versionInfo: versionArgument,
      downloadLocation: `https://github.com/${repository}/tree/${revision}`,
      filesAnalyzed: false,
      licenseConcluded: "MIT",
      licenseDeclared: "MIT",
      copyrightText: "Copyright (c) 2026 Alexander Ilg",
      externalRefs: [
        {
          referenceCategory: "PACKAGE-MANAGER",
          referenceType: "purl",
          referenceLocator: `pkg:github/${repository}@${encodeURIComponent(versionArgument)}`,
        },
      ],
    },
    ...components,
  ],
  relationships: dependencyRefs.map((dependencyRef) => ({
    spdxElementId: applicationRef,
    relationshipType: "DEPENDS_ON",
    relatedSpdxElement: dependencyRef,
  })),
};

await writeFile(path.resolve(outputArgument), `${JSON.stringify(sbom, null, 2)}\n`, {
  flag: "wx",
});
console.log(`Created SPDX 2.3 SBOM: ${path.resolve(outputArgument)}`);
