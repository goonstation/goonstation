#!/usr/bin/env node
// Normalizes all SVG files to use LF line endings

import { glob, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

for await (const file of glob('**/*.svg', { cwd: import.meta.dirname })) {
  const filePath = join(import.meta.dirname, file);
  const content = await readFile(filePath, 'utf8');
  const normalized = content.replace(/\r\n?/g, '\n');
  if (content !== normalized) {
    await writeFile(filePath, normalized, 'utf8');
    console.log(`Normalized: ${file}`);
  }
}

console.log(`SVG normalization complete.`);
