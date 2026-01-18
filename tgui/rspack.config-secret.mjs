/**
 * @file Secret interface handling for rspack builds
 * @copyright 2025 Goonstation
 */
import { createHmac, randomBytes } from 'node:crypto';
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
  const token = deriveSecretToken(interfaceName);
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
  'registry.generated.ts',
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

function ensureSecretSalt() {
  if (!existsSync(secretRepoRoot)) {
    return null;
  }

  mkdirSync(path.dirname(secretSaltFile), { recursive: true });

  if (!existsSync(secretSaltFile)) {
    const salt = randomBytes(32).toString('hex');
    writeFileSync(secretSaltFile, salt);
    return salt;
  }

  const existing = readFileSync(secretSaltFile, 'utf-8').trim();
  return existing || null;
}

function deriveSecretToken(interfaceName) {
  const salt = ensureSecretSalt();
  if (!salt) {
    return null;
  }

  // 24 hex chars = 96 bits: short enough for filenames, large enough to avoid collisions.
  return createHmac('md5', salt)
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
          const token = deriveSecretToken(interfaceName);
          if (!token) {
            continue;
          }

          mapping[interfaceName] = {
            token,
            chunk: `secret-${token}.bundle.js`,
          };

          // Wrapper registers the component into a global registry keyed by token.
          // Import path intentionally omits extension to avoid TS5097.
          const wrapperPath = path.join(
            secretInterfaceTarget,
            `${interfaceName}.wrapper.tsx`,
          );

          const importTarget = entry.endsWith('/')
            ? `./${interfaceName}`
            : `./${interfaceName}`;

          const wrapperContent = `// Auto-generated wrapper for ${interfaceName}\nimport Component from '${importTarget}';\n\nif (!globalThis.__SECRET_TGUI_INTERFACES__) {\n  globalThis.__SECRET_TGUI_INTERFACES__ = {};\n}\n\nglobalThis.__SECRET_TGUI_INTERFACES__['${token}'] = Component;\n\nexport default Component;\n`;
          mkdirSync(path.dirname(wrapperPath), { recursive: true });
          writeFileSync(wrapperPath, wrapperContent);
        }
        copied += 1;
      }

      // Write mapping file (private, in +secret) for DM to read.
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
    const token = info?.token;
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
