/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
import type { ComponentType } from 'react';
import { lazy, Suspense } from 'react';

import { useBackend } from './backend';
import { useDebug } from './debug';
import { loadSecretInterface } from './interfaces-secret';
import { Window } from './layouts';

const requireInterface = require.context('./interfaces');

const secretComponentCache = new Map<string, ComponentType>();

const SECRET_STORAGE_KEY = 'tgui.secretInterfaces';

function loadPersistedSecret(
  name: string,
): { token: string; chunk?: string } | null {
  try {
    const raw = sessionStorage.getItem(SECRET_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    const info = parsed?.[name];
    if (info && typeof info.token === 'string') {
      return { token: info.token };
    }
  } catch {
    // ignore storage/parse errors
  }
  return null;
}

function persistSecret(name: string, info: { token: string }) {
  try {
    const raw = sessionStorage.getItem(SECRET_STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : {};
    parsed[name] = info;
    sessionStorage.setItem(SECRET_STORAGE_KEY, JSON.stringify(parsed));
  } catch {
    // ignore storage errors (storage disabled/full)
  }
}

const routingError =
  (type: 'notFound' | 'missingExport', name: string) => () => {
    return (
      <Window>
        <Window.Content scrollable>
          {type === 'notFound' && (
            <div>
              Interface <b>{name}</b> was not found.
            </div>
          )}
          {type === 'missingExport' && (
            <div>
              Interface <b>{name}</b> is missing an export.
            </div>
          )}
        </Window.Content>
      </Window>
    );
  };

// Displays an empty Window with scrollable content
const SuspendedWindow = () => {
  return (
    <Window>
      <Window.Content scrollable />
    </Window>
  );
};

/* |GOONSTATION-CHANGE| - we add a spinner to the top right instead
// Displays a loading screen with a spinning icon
const RefreshingWindow = () => {
  return (
    <Window title="Loading">
      <Window.Content>
        <LoadingScreen />
      </Window.Content>
    </Window>
  );
};
*/

// Get the component for the current route
export function getRoutedComponent() {
  const { suspended, config } = useBackend();
  const { kitchenSink = false } = useDebug();

  if (suspended) {
    return SuspendedWindow;
  }
  /* |GOONSTATION-CHANGE| - we add a spinner to the top right instead
  if (config?.refreshing) {
    return RefreshingWindow;
  }
  */

  if (process.env.NODE_ENV !== 'production' && kitchenSink) {
    const { KitchenSink } = require('./debug');
    return KitchenSink;
  }

  const name = config?.interface?.name;

  let secretInfo = name ? config?.secretInterfaces?.[name] : null;

  // Fallback for CTRL+R reloads: reuse last-seen secret token/chunk from sessionStorage.
  if (!secretInfo && name) {
    secretInfo = loadPersistedSecret(name);
  }

  if (name && secretInfo?.token) {
    persistSecret(name, secretInfo);
    return getSecretComponent(name, secretInfo.token);
  }

  const interfacePathBuilders = [
    (name: string) => `./${name}.tsx`,
    (name: string) => `./${name}.jsx`,
    (name: string) => `./${name}/index.tsx`,
    (name: string) => `./${name}/index.jsx`,
  ];

  let esModule;
  while (!esModule && interfacePathBuilders.length > 0) {
    const interfacePathBuilder = interfacePathBuilders.shift()!;
    const interfacePath = interfacePathBuilder(name);
    try {
      esModule = requireInterface(interfacePath);
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') {
        throw err;
      }
    }
  }

  if (!esModule) {
    return routingError('notFound', name);
  }

  const Component = esModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }

  return Component;
}

function getSecretComponent(name: string, token: string): ComponentType {
  const cached = secretComponentCache.get(name);
  if (cached) {
    return cached;
  }

  const LazySecret = lazy(async () => {
    const Component = await loadSecretInterface(token);
    return { default: Component };
  });

  const WrappedSecret: ComponentType = () => {
    return (
      <Suspense fallback={<SuspendedWindow />}>
        <LazySecret />
      </Suspense>
    );
  };

  secretComponentCache.set(name, WrappedSecret);
  return WrappedSecret;
}
