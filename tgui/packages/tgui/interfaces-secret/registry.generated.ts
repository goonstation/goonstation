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

export function hasSecretInterface(uuid: string): boolean {
  return Boolean(globalThis.__SECRET_TGUI_INTERFACES__?.[uuid]);
}

export function loadSecretInterface(
  uuid: string,
  chunkFilename: string,
): Promise<ComponentType> {
  const existing = globalThis.__SECRET_TGUI_INTERFACES__?.[uuid];
  if (existing) {
    return Promise.resolve(existing);
  }

  const cached = loaded.get(uuid);
  if (cached) {
    return cached;
  }

  const promise = new Promise<ComponentType>((resolve, reject) => {
    const script = document.createElement('script');
    script.async = true;
    script.src = `/${chunkFilename}`;

    script.onload = () => {
      const component = globalThis.__SECRET_TGUI_INTERFACES__?.[uuid];
      if (component) {
        resolve(component);
      } else {
        reject(
          new Error(`Secret chunk loaded but component "${uuid}" not found`),
        );
      }
    };

    script.onerror = () => {
      loaded.delete(uuid);
      reject(new Error(`Failed to load secret chunk: ${chunkFilename}`));
    };

    document.head.appendChild(script);
  });

  loaded.set(uuid, promise);
  return promise;
}
