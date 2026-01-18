/**
 * @file Secret interface handling for rspack builds
 * @copyright 2025 Goonstation
 */
import { createHash } from 'node:crypto';
import { cpSync, existsSync, mkdirSync, readdirSync, rmSync } from 'node:fs';

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

  // eslint-disable-next-line sonarjs/hashing
  const hash = createHash('md5')
    .update(interfaceName)
    .digest('hex')
    .slice(0, 12);
  return `secret-${hash}`;
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
const secretInterfacePreserve = new Set(['.gitignore', 'index.ts']);
const secretBundleDestination = path.resolve(
  secretRepoRoot,
  'browserassets',
  'src',
  'tgui',
);
const secretDestinationPreserve = new Set(['.gitignore']);
const secretBundlePattern = /^secret-.*\.bundle\.js(?:\.map)?$/i;

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

      let copied = 0;

      for (const entry of entries) {
        const sourcePath = path.join(secretInterfaceSource, entry);
        const targetPath = path.join(secretInterfaceTarget, entry);

        cpSync(sourcePath, targetPath, { recursive: true });
        copied += 1;
      }

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

export const secretInterfacesSplitChunks = {
  test: /[\\/]interfaces-secret[\\/].+\.[tj]sx?$/,
  name(module) {
    return deriveSecretChunkName(module.identifier()) || undefined;
  },
  enforce: true,
  priority: 40,
};
