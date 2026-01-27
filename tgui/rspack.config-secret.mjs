/**
 * @file Secret interface handling for rspack builds
 * @copyright 2026 ZeWaka
 * @license MIT
 */
import { createHmac } from 'node:crypto';
import {
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';

import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const secretRepoRoot = path.resolve(__dirname, '../+secret');
const secretInterfaceSource = path.resolve(
  secretRepoRoot,
  'tgui',
  'interfaces',
);
const secretInterfaceTarget = path.resolve(
  __dirname,
  'packages',
  'tgui',
  'interfaces-secret',
);
const secretInterfacePreserve = new Set([
  '.gitignore',
  'index.ts',
  'dummy.tsx',
  'dummy.wrapper.tsx',
]);
const secretBundleDestination = path.resolve(
  secretRepoRoot,
  'browserassets',
  'src',
  'tgui',
);
const secretMappingFile = path.resolve(
  secretRepoRoot,
  'tgui',
  'secret-mapping.json',
);
const secretSaltFile = path.resolve(secretRepoRoot, 'tgui', 'secret-salt.txt');
const secretDestinationPreserve = new Set(['.gitignore']);
const secretBundlePattern = /^secret-.*\.bundle\.js(?:\.map)?$/i;
const wrapperPattern = /\.wrapper\.tsx$/i;
const isWrapperFile = (entry) => wrapperPattern.test(entry);

const listInterfaceEntries = (dir) =>
  readdirSync(dir).filter(
    (entry) => !secretInterfacePreserve.has(entry) && !isWrapperFile(entry),
  );

const fileMtimeMs = (fullPath) => {
  try {
    const stat = statSync(fullPath);
    return stat.mtimeMs || 0;
  } catch {
    return 0;
  }
};

/**
 * @param {string} entry
 * @returns {string | null}
 */
function deriveInterfaceNameFromEntry(entry) {
  if (!entry) {
    return null;
  }

  const normalized = entry.replace(/\\/g, '/');
  const segments = normalized.split('/').filter(Boolean);

  if (!segments.length) {
    return null;
  }

  const last = segments[segments.length - 1];
  const withoutExt = last.replace(/\.[tj]sx?$/i, '');

  if (withoutExt === 'index' && segments.length > 1) {
    return segments[segments.length - 2];
  }

  return withoutExt || null;
}

/**
 * @param {string} interfaceName
 * @returns {string | null}
 */
function deriveSecretId(interfaceName) {
  if (!existsSync(secretRepoRoot)) {
    return null;
  }

  if (!existsSync(secretSaltFile)) {
    throw new Error(`Missing secret salt file at ${secretSaltFile}.`);
  }

  const seasoningSalt = readFileSync(secretSaltFile, 'utf-8').trim();
  if (!seasoningSalt) {
    throw new Error(`Secret salt is empty at ${secretSaltFile}.`);
  }

  return createHmac('md5', seasoningSalt)
    .update(String(interfaceName))
    .digest('hex')
    .slice(0, 24);
}

export class SecretInterfaceSyncPlugin {
  /** @param {import('@rspack/core').Compiler} compiler */
  apply(compiler) {
    const logger = compiler.getInfrastructureLogger(
      'SecretInterfaceSyncPlugin',
    );

    const syncSecrets = () => {
      let sourceDir, targetDir, sourceLabel, entries, mergeMode;

      const hasSecretRepo =
        existsSync(secretRepoRoot) && existsSync(secretInterfaceSource);
      const hasTargetContent = existsSync(secretInterfaceTarget);

      const secretEntries = hasSecretRepo
        ? listInterfaceEntries(secretInterfaceSource)
        : [];
      const publicEntries = hasTargetContent
        ? listInterfaceEntries(secretInterfaceTarget)
        : [];

      if (!secretEntries.length && !publicEntries.length) {
        logger.debug(
          'No secret interfaces found in either location; skipping sync.',
        );
        return;
      }

      if (secretEntries.length && publicEntries.length) {
        mergeMode = true;
        entries = Array.from(new Set([...secretEntries, ...publicEntries]));
        sourceLabel = 'bidirectional merge';
      } else if (secretEntries.length) {
        sourceDir = secretInterfaceSource;
        targetDir = secretInterfaceTarget;
        sourceLabel = '+secret → interfaces-secret';
        entries = secretEntries;
      } else {
        sourceDir = secretInterfaceTarget;
        targetDir = secretInterfaceSource;
        sourceLabel = 'interfaces-secret → +secret';
        entries = publicEntries;
      }

      if (mergeMode) {
        mkdirSync(secretInterfaceSource, { recursive: true });
        mkdirSync(secretInterfaceTarget, { recursive: true });
      } else {
        mkdirSync(targetDir, { recursive: true });
      }

      if (!mergeMode) {
        // only remove files that were previously synced but no longer exist in source
        const sourceNames = new Set(
          entries.map((e) => e.replace(/\.[^.]+$/, '')),
        );

        for (const entry of readdirSync(targetDir)) {
          if (secretInterfacePreserve.has(entry)) {
            continue;
          }

          // wrappers are auto-generated
          if (isWrapperFile(entry)) {
            continue;
          }

          const baseName = entry.replace(/\.[^.]+$/, '');
          if (!sourceNames.has(baseName)) {
            rmSync(path.join(targetDir, entry), {
              recursive: true,
              force: true,
            });
          }
        }
      }

      const mapping = {};
      let copied = 0;

      for (const entry of entries) {
        let entrySourceDir = sourceDir;
        let entryTargetDir = targetDir;

        if (mergeMode) {
          const secretPath = path.join(secretInterfaceSource, entry);
          const publicPath = path.join(secretInterfaceTarget, entry);
          const hasSecret = existsSync(secretPath);
          const hasPublic = existsSync(publicPath);

          if (hasSecret && hasPublic) {
            const secretMtime = fileMtimeMs(secretPath);
            const publicMtime = fileMtimeMs(publicPath);
            if (publicMtime > secretMtime) {
              entrySourceDir = secretInterfaceTarget;
              entryTargetDir = secretInterfaceSource;
            } else {
              entrySourceDir = secretInterfaceSource;
              entryTargetDir = secretInterfaceTarget;
            }
          } else if (hasSecret) {
            entrySourceDir = secretInterfaceSource;
            entryTargetDir = secretInterfaceTarget;
          } else {
            entrySourceDir = secretInterfaceTarget;
            entryTargetDir = secretInterfaceSource;
          }
        }

        const sourcePath = path.join(entrySourceDir, entry);
        const targetPath = path.join(entryTargetDir, entry);

        cpSync(sourcePath, targetPath, { recursive: true });

        const interfaceName = deriveInterfaceNameFromEntry(entry);
        if (interfaceName) {
          const id = deriveSecretId(interfaceName);
          if (!id) {
            continue;
          }

          mapping[interfaceName] = id;

          // Always write wrappers into interfaces-secret (the build source)
          const wrapperPath = path.join(
            secretInterfaceTarget,
            `${interfaceName}.wrapper.tsx`,
          );

          const importTarget = `./${interfaceName}`;

          const wrapperContent = `import Component from '${importTarget}';
// @ts-ignore
globalThis.__SECRET_TGUI_INTERFACES__['${id}'] = Component;
export default Component;\n`;
          mkdirSync(path.dirname(wrapperPath), { recursive: true });
          writeFileSync(wrapperPath, wrapperContent);
        }
        copied += 1;
      }

      // write mapping file
      if (existsSync(secretRepoRoot)) {
        mkdirSync(path.dirname(secretMappingFile), { recursive: true });
        writeFileSync(secretMappingFile, JSON.stringify(mapping, null, 2));
      }

      if (copied > 0) {
        logger.log(
          `Synced ${copied} secret interface${copied === 1 ? '' : 's'} (${sourceLabel})`,
        );
      }
    };

    compiler.hooks.beforeRun.tap('SecretInterfaceSyncPlugin', syncSecrets);
    compiler.hooks.watchRun.tap('SecretInterfaceSyncPlugin', syncSecrets);
  }
}

export class SecretBundleStoragePlugin {
  /** @param {import('@rspack/core').Compiler} compiler */
  apply(compiler) {
    const logger = compiler.getInfrastructureLogger(
      'SecretBundleStoragePlugin',
    );

    compiler.hooks.done.tap('SecretBundleStoragePlugin', (stats) => {
      const compilation = stats.compilation;
      if (!compilation || compilation.options.mode !== 'production') {
        return;
      }

      if (!existsSync(secretRepoRoot)) {
        return;
      }

      const outputPath = compiler.options.output.path;
      if (!outputPath) {
        return;
      }

      const filesToMirror = new Set();
      const filesToDelete = new Set();

      for (const chunk of compilation.chunks) {
        if (!chunk?.name || !chunk.name.startsWith('secret-')) {
          continue;
        }

        if (chunk.name === 'secret-dummy') {
          continue;
        }

        for (const file of [
          ...(chunk.files ?? []),
          ...(chunk.auxiliaryFiles ?? []),
        ]) {
          if (secretBundlePattern.test(file)) {
            filesToDelete.add(file);
            filesToMirror.add(file);
          }
        }
      }

      if (!filesToMirror.size && !filesToDelete.size) {
        return;
      }

      if (filesToMirror.size) {
        // Clean up old bundles that are no longer in the build
        if (existsSync(secretBundleDestination)) {
          for (const entry of readdirSync(secretBundleDestination)) {
            if (secretDestinationPreserve.has(entry)) {
              continue;
            }

            if (!secretBundlePattern.test(entry)) {
              continue;
            }

            if (filesToMirror.has(entry)) {
              continue;
            }

            rmSync(path.join(secretBundleDestination, entry), {
              force: true,
            });
          }
        }

        mkdirSync(secretBundleDestination, { recursive: true });

        for (const file of filesToMirror) {
          const sourcePath = path.join(outputPath, file);

          if (!existsSync(sourcePath)) {
            continue;
          }

          const destinationPath = path.join(secretBundleDestination, file);
          cpSync(sourcePath, destinationPath);
        }
      }

      // Strip secret bundles back out of the public output so they only live in +secret.
      for (const file of filesToDelete) {
        const sourcePath = path.join(outputPath, file);
        if (existsSync(sourcePath)) {
          rmSync(sourcePath, { force: true });
        }
      }

      if (filesToMirror.size) {
        logger.log(
          `Stored ${filesToMirror.size} secret bundle${
            filesToMirror.size === 1 ? '' : 's'
          } in +secret`,
        );
      }
    });
  }
}

/** @param {import('@rspack/core').Configuration} config */
export function addSecretInterfaceEntries(config) {
  const dummyPath = path.join(secretInterfaceTarget, 'dummy.tsx');
  if (existsSync(dummyPath)) {
    config.entry['secret-dummy'] = {
      import: [dummyPath],
      dependOn: 'tgui',
    };
  }

  if (!existsSync(secretMappingFile)) {
    return;
  }

  let mapping;
  try {
    mapping = JSON.parse(readFileSync(secretMappingFile, 'utf-8'));
  } catch {
    return;
  }

  for (const [interfaceName, id] of Object.entries(mapping)) {
    const wrapperPath = path.join(
      secretInterfaceTarget,
      `${interfaceName}.wrapper.tsx`,
    );

    if (!existsSync(wrapperPath)) {
      continue;
    }

    const entryName = `secret-${id}`;
    config.entry[entryName] = {
      import: [wrapperPath],
      dependOn: 'tgui',
    };
  }
}
