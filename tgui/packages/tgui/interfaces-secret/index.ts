/**
 * Secret interface registry.
 *
 * This file is tracked in the public repository and purposely contains no
 * secret interface implementations. Maintain the actual secret interfaces as
 * untracked files within this directory (ignored via .gitignore) or copy them
 * in from the +secret submodule before building. Any `.tsx` file (excluding
 * this one) located here will automatically be picked up and exposed through
 * lazy loaders.
 */

import type { ComponentType } from 'react';

type SecretInterfaceLoader = () => Promise<ComponentType>;

type SecretRegistry = Record<string, SecretInterfaceLoader>;

const SECRET_CONTEXT = safeCreateContext();

const SECRET_REGISTRY: SecretRegistry = SECRET_CONTEXT
  ? buildRegistry(SECRET_CONTEXT)
  : {};

export const secretInterfaceNames = Object.freeze(Object.keys(SECRET_REGISTRY));

export function hasSecretInterface(name: string): boolean {
  return Boolean(SECRET_REGISTRY[name]);
}

export function loadSecretInterface(name: string): Promise<ComponentType> {
  const loader = SECRET_REGISTRY[name];

  if (!loader) {
    return Promise.reject(
      new Error(`Secret interface "${name}" is not registered.`),
    );
  }

  return loader();
}

function buildRegistry(
  context: ReturnType<typeof require.context>,
): SecretRegistry {
  const entries: SecretRegistry = {};

  for (const key of context.keys()) {
    const interfaceName = deriveInterfaceName(key);

    if (!interfaceName || entries[interfaceName]) {
      continue;
    }

    entries[interfaceName] = createLazyLoader(context, key, interfaceName);
  }

  return entries;
}

function createLazyLoader(
  context: ReturnType<typeof require.context>,
  key: string,
  interfaceName: string,
): SecretInterfaceLoader {
  return async () => {
    const moduleExports = (await context(key)) as Record<string, ComponentType>;

    const component =
      moduleExports.default ??
      moduleExports[interfaceName] ??
      firstComponent(moduleExports);

    if (!component) {
      throw new Error(
        `Secret interface "${interfaceName}" is missing a component export.
Ensure that the module exports the component either as the default export or a named export matching the interface name.`,
      );
    }

    return component;
  };
}

function firstComponent(
  moduleExports: Record<string, ComponentType>,
): ComponentType | undefined {
  for (const value of Object.values(moduleExports)) {
    if (typeof value === 'function') {
      return value;
    }
  }
  return undefined;
}

function deriveInterfaceName(key: string): string | null {
  const normalized = key.replace(/^\.\//, '').replace(/\.[tj]sx?$/, '');

  if (!normalized) {
    return null;
  }

  if (normalized.endsWith('/index')) {
    const segments = normalized.split('/');
    segments.pop();
    return segments.pop() ?? null;
  }

  const segments = normalized.split('/');
  return segments.pop() ?? null;
}

function safeCreateContext(): ReturnType<typeof require.context> | null {
  try {
    return require.context(
      '.',
      true,
      /^\.\/(?!index\.[tj]sx?$).*\.[tj]sx$/,
      'lazy',
    );
  } catch (error: unknown) {
    if (process.env.NODE_ENV !== 'production') {
      console.warn('Secret interface context is unavailable:', error);
    }
    return null;
  }
}
