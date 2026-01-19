/**
 * @file Secret interface handling for rspack builds
 * @copyright 2025 Goonstation
 */
import { createHmac } from 'node:crypto';
import {
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';

import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function deriveSecretChunkName(identifier) {
  const match = identifier.match(/interfaces-secret[\\/](.+?)\.[tj]sx?$/i);

  if (!match) {
    return null;
  }

  const raw = match[1].replace(/\\/g, '/');
  const segments = raw.split('/');

  if (!segments.length) {
    return null;
  }

  const last = segments[segments.length - 1];
  const interfaceName =
    last === 'index' && segments.length > 1
      ? segments[segments.length - 2]
      : last;

  return deriveSecretChunkNameFromInterfaceName(interfaceName);
}

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

function deriveSecretChunkNameFromInterfaceName(interfaceName) {
  const token = deriveSecretId(interfaceName);
  if (!token) {
    return null;
  }

  return `secret-${token}`;
}

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
  apply(compiler) {
    const logger = compiler.getInfrastructureLogger(
      'SecretInterfaceSyncPlugin',
    );

    const syncSecrets = () => {
      if (!existsSync(secretRepoRoot)) {
        return;
      }

      if (!existsSync(secretInterfaceSource)) {
        logger.debug('Secret interface source not found; skipping sync.');
        return;
      }

      const entries = readdirSync(secretInterfaceSource);

      if (!entries.length) {
        logger.debug('Secret interface source is empty; skipping sync.');
        return;
      }

      mkdirSync(secretInterfaceTarget, { recursive: true });

      for (const entry of readdirSync(secretInterfaceTarget)) {
        if (secretInterfacePreserve.has(entry)) {
          continue;
        }

        rmSync(path.join(secretInterfaceTarget, entry), {
          recursive: true,
          force: true,
        });
      }

      const mapping = {};
      let copied = 0;

      for (const entry of entries) {
        const sourcePath = path.join(secretInterfaceSource, entry);
        const targetPath = path.join(secretInterfaceTarget, entry);

        cpSync(sourcePath, targetPath, { recursive: true });

        const interfaceName = deriveInterfaceNameFromEntry(entry);
        if (interfaceName) {
          const id = deriveSecretId(interfaceName);
          if (!id) {
            continue;
          }

          mapping[interfaceName] = id;

          // Wrapper registers the component into a global registry keyed by id.
          const wrapperPath = path.join(
            secretInterfaceTarget,
            `${interfaceName}.wrapper.tsx`,
          );

          const importTarget = `./${interfaceName}`;

          const wrapperContent = `// Auto-generated wrapper for ${interfaceName}
import Component from '${importTarget}';\n// @ts-ignore
globalThis.__SECRET_TGUI_INTERFACES__['${id}'] = Component;
export default Component;\n`;
          mkdirSync(path.dirname(wrapperPath), { recursive: true });
          writeFileSync(wrapperPath, wrapperContent);
        }
        copied += 1;
      }

      // Write mapping file for the server to read.
      mkdirSync(path.dirname(secretMappingFile), { recursive: true });
      writeFileSync(secretMappingFile, JSON.stringify(mapping, null, 2));

      if (copied > 0) {
        logger.log(
          `Synced ${copied} secret interface${copied === 1 ? '' : 's'} to tgui`,
        );
      }
    };

    compiler.hooks.beforeRun.tap('SecretInterfaceSyncPlugin', syncSecrets);
    compiler.hooks.watchRun.tap('SecretInterfaceSyncPlugin', syncSecrets);
  }
}

export class SecretBundleStoragePlugin {
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

      for (const chunk of compilation.chunks) {
        if (!chunk?.name || !chunk.name.startsWith('secret-')) {
          continue;
        }

        for (const file of chunk.files ?? []) {
          if (secretBundlePattern.test(file)) {
            filesToMirror.add(file);
          }
        }

        for (const file of chunk.auxiliaryFiles ?? []) {
          if (secretBundlePattern.test(file)) {
            filesToMirror.add(file);
          }
        }
      }

      if (!filesToMirror.size && !existsSync(secretBundleDestination)) {
        return;
      }

      const cleanupDestination = (keep) => {
        if (!existsSync(secretBundleDestination)) {
          return;
        }

        for (const entry of readdirSync(secretBundleDestination)) {
          if (secretDestinationPreserve.has(entry)) {
            continue;
          }

          if (!secretBundlePattern.test(entry)) {
            continue;
          }

          if (keep.has(entry)) {
            continue;
          }

          rmSync(path.join(secretBundleDestination, entry), {
            force: true,
          });
        }
      };

      cleanupDestination(filesToMirror);

      if (!filesToMirror.size) {
        return;
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

      // Strip secret bundles back out of the public output so they only live in +secret.
      for (const file of filesToMirror) {
        const sourcePath = path.join(outputPath, file);
        if (existsSync(sourcePath)) {
          rmSync(sourcePath, { force: true });
        }
      }

      logger.log(
        `Stored ${filesToMirror.size} secret bundle${
          filesToMirror.size === 1 ? '' : 's'
        } in +secret`,
      );
    });
  }
}

export function addSecretInterfaceEntries(config) {
  if (!existsSync(secretMappingFile)) {
    return;
  }

  let mapping;
  try {
    mapping = JSON.parse(readFileSync(secretMappingFile, 'utf-8'));
  } catch {
    return;
  }

  for (const [interfaceName, info] of Object.entries(mapping)) {
    const token = typeof info === 'string' ? info : null;
    if (!token) {
      continue;
    }

    const wrapperPath = path.join(
      secretInterfaceTarget,
      `${interfaceName}.wrapper.tsx`,
    );

    if (!existsSync(wrapperPath)) {
      continue;
    }

    const entryName = `secret-${token}`;
    config.entry[entryName] = {
      import: [wrapperPath],
      dependOn: 'tgui',
    };
  }
}
