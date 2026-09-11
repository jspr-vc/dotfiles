#!/usr/bin/env bun
// Read packages/*.ts and print one package per line.
//
//   packages.ts list  <file>...   flatten every group into package names
//   packages.ts check <file>...   exit 1 if any name is unknown to pacman or the AUR

import { resolve } from "node:path";
import type { PackageList } from "../packages/types";

async function flatten(files: string[]): Promise<string[]> {
  const names = new Set<string>();
  for (const file of files) {
    const mod = (await import(resolve(file))) as { default?: PackageList };
    if (!mod.default) continue; // types.ts and the like
    for (const group of Object.values(mod.default)) {
      for (const name of Object.keys(group)) names.add(name);
    }
  }
  return [...names];
}

function check(names: string[]): number {
  const helper = Bun.which("yay") ?? "pacman";
  const result = Bun.spawnSync([helper, "-Si", ...names]);
  const unknown: string[] = [];
  for (const line of result.stderr.toString().split("\n")) {
    // pacman: error: package 'x' was not found
    // yay:    -> No AUR package found for x
    const pacman = line.match(/package '([^']+)' was not found/);
    const yay = line.match(/No AUR package found for (\S+)/);
    const name = pacman?.[1] ?? yay?.[1];
    if (name) unknown.push(name);
  }
  for (const name of unknown) console.error(`unknown package: ${name}`);
  return unknown.length ? 1 : 0;
}

const [command, ...files] = process.argv.slice(2);
if ((command !== "list" && command !== "check") || files.length === 0) {
  console.error("usage: packages.ts list|check <file>...");
  process.exit(2);
}

const names = await flatten(files);
if (command === "list") {
  console.log(names.join("\n"));
} else {
  process.exit(check(names));
}
