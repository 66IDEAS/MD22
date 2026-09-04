import { build } from "esbuild";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const output = resolve(root, "MD22/Resources/Renderer");
await mkdir(output, { recursive: true });

await build({
  entryPoints: [
    resolve(root, "web/renderer-entry.js"),
    resolve(root, "web/mermaid-entry.js"),
    resolve(root, "web/base.css")
  ],
  bundle: true,
  minify: true,
  sourcemap: false,
  outdir: output,
  entryNames: "[name]",
  assetNames: "assets/[name]-[hash]",
  loader: { ".woff2": "dataurl", ".woff": "dataurl", ".ttf": "dataurl" },
  legalComments: "eof",
  target: ["safari26"]
});

const licenses = [
  ["markdown-it", "LICENSE"], ["markdown-it-anchor", "LICENSE"],
  ["markdown-it-container", "LICENSE"], ["markdown-it-footnote", "LICENSE"],
  ["markdown-it-task-lists", "LICENSE"], ["markdown-it-texmath", "license.txt"],
  ["katex", "LICENSE"], ["highlight.js", "LICENSE"], ["mermaid", "LICENSE"],
  ["dompurify", "LICENSE"]
];
let notices = "MD22 Bundled Renderer Licenses\n================================\n";
for (const [name, file] of licenses) {
  const path = resolve(root, "node_modules", name, file);
  let licenseText;
  try {
    licenseText = await readFile(path, "utf8");
  } catch (error) {
    if (error.code !== "ENOENT") throw error;
    const metadata = JSON.parse(await readFile(resolve(root, "node_modules", name, "package.json"), "utf8"));
    licenseText = `Package metadata declares license: ${metadata.license || "unspecified"}.`;
  }
  notices += `\n\n--- ${name} ---\n\n${licenseText}`;
}
await writeFile(resolve(output, "THIRD_PARTY_LICENSES.txt"), notices);
