/**
 * @file Secret interface routing and persistence utilities
 * @copyright 2025 ZeWaka
 * @license MIT
 *
 * @description Secret interface runtime loading mechanisms.
 * This file is tracked in the public repository.
 */
import type { ComponentType } from 'react';

declare global {
  var __SECRET_TGUI_INTERFACES__: Record<string, ComponentType> | undefined;
}

if (!globalThis.__SECRET_TGUI_INTERFACES__) {
  globalThis.__SECRET_TGUI_INTERFACES__ = {};
}

const loaded = new Map<string, Promise<ComponentType>>();

export function loadSecretInterface(id: string): Promise<ComponentType> {
  const existing = globalThis.__SECRET_TGUI_INTERFACES__?.[id];
  if (existing) {
    return Promise.resolve(existing);
  }

  const cached = loaded.get(id);
  if (cached) {
    return cached;
  }

  const bundle = `secret-${id}.bundle.js`;

  const promise = new Promise<ComponentType>((resolve, reject) => {
    const script = document.createElement('script');
    script.async = true;
    script.src = `/${bundle}`;

    script.onload = () => {
      const component = globalThis.__SECRET_TGUI_INTERFACES__?.[id];
      if (component) {
        resolve(component);
      } else {
        reject(
          new Error(`Secret bundle loaded but component "${id}" not found`),
        );
      }
    };

    script.onerror = () => {
      loaded.delete(id);
      reject(new Error(`Failed to load secret bundle: ${bundle}`));
    };

    document.head.appendChild(script);
  });

  loaded.set(id, promise);
  return promise;
}
