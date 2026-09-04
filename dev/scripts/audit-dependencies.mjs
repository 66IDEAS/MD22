#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

const scriptsDirectory = path.dirname(fileURLToPath(import.meta.url));
const projectDirectory = path.dirname(scriptsDirectory);

const allowedLicenses = new Set([
  "(MPL-2.0 OR Apache-2.0)",
  "Apache-2.0",
  "BSD-2-Clause",
  "BSD-3-Clause",
  "ISC",
  "MIT",
  "PSF-2.0",
  "Unlicense",
]);
const reviewedMissingLicenseMetadata = new Map([
  ["node_modules/khroma@2.1.0", "MIT"],
]);

const lockfile = JSON.parse(
  await readFile(path.join(projectDirectory, "package-lock.json"), "utf8"),
);
const swiftResolution = JSON.parse(
  await readFile(path.join(projectDirectory, "Package.resolved"), "utf8"),
);

const failures = [];

if (lockfile.lockfileVersion !== 3) {
  failures.push(`package-lock.json must use lockfileVersion 3, found ${lockfile.lockfileVersion}`);
}

for (const [packagePath, metadata] of Object.entries(lockfile.packages ?? {})) {
  if (packagePath === "") {
    continue;
  }

  if (!metadata.version || !metadata.integrity) {
    failures.push(`${packagePath} is not pinned by version and integrity`);
  }

  const reviewedLicense = reviewedMissingLicenseMetadata.get(`${packagePath}@${metadata.version}`);
  const license = metadata.license ?? reviewedLicense;
  if (!license) {
    failures.push(`${packagePath} does not declare a license`);
  } else if (!allowedLicenses.has(license)) {
    failures.push(`${packagePath} uses a license outside policy: ${license}`);
  }
}

for (const reviewedPackage of reviewedMissingLicenseMetadata.keys()) {
  const [packagePath, version] = reviewedPackage.split("@");
  if (lockfile.packages?.[packagePath]?.version !== version) {
    failures.push(`Reviewed license override is stale: ${reviewedPackage}`);
  }
}

const approvedSwiftPackages = new Map([
  ["sparkle", { license: "MIT", location: "https://github.com/sparkle-project/Sparkle" }],
]);

for (const pin of swiftResolution.pins ?? []) {
  const approved = approvedSwiftPackages.get(pin.identity);
  if (!approved) {
    failures.push(`Swift package ${pin.identity} has not received a license-policy review`);
    continue;
  }
  if (pin.location !== approved.location) {
    failures.push(`Swift package ${pin.identity} resolved from an unexpected location: ${pin.location}`);
  }
  if (!pin.state?.version || !/^[0-9a-f]{40}$/u.test(pin.state?.revision ?? "")) {
    failures.push(`Swift package ${pin.identity} is not pinned by version and revision`);
  }
  if (!allowedLicenses.has(approved.license)) {
    failures.push(`Swift package ${pin.identity} uses a license outside policy: ${approved.license}`);
  }
}

for (const identity of approvedSwiftPackages.keys()) {
  if (!(swiftResolution.pins ?? []).some((pin) => pin.identity === identity)) {
    failures.push(`Approved Swift package ${identity} is missing from Package.resolved`);
  }
}

if (failures.length > 0) {
  console.error("Dependency policy failed:");
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

const npmCount = Object.keys(lockfile.packages ?? {}).filter((entry) => entry !== "").length;
const swiftCount = (swiftResolution.pins ?? []).length;
console.log(`Dependency policy passed for ${npmCount} npm and ${swiftCount} Swift package records.`);
