/**
 * @file Secret interface routing and persistence utilities
 * @copyright 2025 ZeWaka
 * @license MIT
 */
import type { ComponentType } from 'react';
import { lazy, Suspense } from 'react';

import { loadSecretInterface } from './interfaces-secret';

const secretComponentCache = new Map<string, ComponentType>();
const SECRET_STORAGE_KEY = 'tgui.secretInterfaces';

/**
 * Attempt to load persisted secret interface id from sessionStorage
 */
export function loadPersistedSecretID(name: string): string | null {
  try {
    const raw = sessionStorage.getItem(SECRET_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    const id = parsed?.[name];
    return id;
  } catch {
    // ignore storage/parse errors
  }
  return null;
}

/**
 * Persist secret interface id to sessionStorage
 */
export function persistSecretID(name: string, id: string): void {
  try {
    const raw = sessionStorage.getItem(SECRET_STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : {};
    parsed[name] = id;
    sessionStorage.setItem(SECRET_STORAGE_KEY, JSON.stringify(parsed));
  } catch {
    // ignore storage errors (storage disabled/full)
  }
}

/**
 * Get or create a lazy-loaded secret component
 */
export function getSecretComponent(name: string, id: string): ComponentType {
  const cached = secretComponentCache.get(name);
  if (cached) {
    return cached;
  }

  const LazySecret = lazy(async () => {
    const Component = await loadSecretInterface(id);
    return { default: Component };
  });

  const WrappedSecret: ComponentType = () => {
    return (
      <Suspense fallback={null}>
        <LazySecret />
      </Suspense>
    );
  };

  secretComponentCache.set(name, WrappedSecret);
  return WrappedSecret;
}
