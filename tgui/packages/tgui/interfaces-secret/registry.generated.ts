/**
 * Secret interface runtime loader.
 *
 * This file is intentionally safe to ship publicly: it contains no secret
 * interface names, UUIDs, or filenames.
 */

import type { ComponentType } from 'react';

declare global {
  // eslint-disable-next-line no-var
  var __SECRET_TGUI_INTERFACES__: Record<string, ComponentType> | undefined;
}

const loaded = new Map<string, Promise<ComponentType>>();

export function hasSecretInterface(token: string): boolean {
  return Boolean(globalThis.__SECRET_TGUI_INTERFACES__?.[token]);
}

export function loadSecretInterface(
  token: string,
  chunkFilename?: string,
): Promise<ComponentType> {
  const existing = globalThis.__SECRET_TGUI_INTERFACES__?.[token];
  if (existing) {
    return Promise.resolve(existing);
  }

  const cached = loaded.get(token);
  if (cached) {
    return cached;
  }

  const resolvedChunk = chunkFilename || `secret-${token}.bundle.js`;

  const promise = new Promise<ComponentType>((resolve, reject) => {
    const script = document.createElement('script');
    script.async = true;
    script.src = `/${resolvedChunk}`;

    script.onload = () => {
      const component = globalThis.__SECRET_TGUI_INTERFACES__?.[token];
      if (component) {
        resolve(component);
      } else {
        reject(
          new Error(`Secret chunk loaded but component "${token}" not found`),
        );
      }
    };

    script.onerror = () => {
      loaded.delete(token);
      reject(new Error(`Failed to load secret chunk: ${resolvedChunk}`));
    };

    document.head.appendChild(script);
  });

  loaded.set(token, promise);
  return promise;
}
