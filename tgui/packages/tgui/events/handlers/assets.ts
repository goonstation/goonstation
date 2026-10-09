import { loadMappings } from 'common/assets';
import { fetchRetry } from 'tgui-core/http';

import { loadedMappings } from '../../assets';
import { gameDataAtom, store } from '../store'; // |GOONSTATION-ADD|

// --------- Handlers ------------------------------------------------------///

export function handleLoadAssets(payload: Record<string, string>): void {
  loadMappings(payload, loadedMappings);

  // |GOONSTATION-CHANGE| Versioned icon map loading.
  if ('icon_ref_map.json' in payload) {
    updateIconRefMap(payload['icon_ref_map.json']);
  }
}

// --------- Helpers -------------------------------------------------------///

// https://biomejs.dev/linter/rules/no-assign-in-expressions/
function setIconRefMap(map: Record<string, string>): void {
  Byond.iconRefMap = map;
}

// |GOONSTATION-ADD| Versioned icon map loading.

let iconRefMapUrl: string | undefined;
let iconRefMapRequest: Promise<void> | undefined;
let iconRefMapRequestId = 0;
let loadedIconRefMapUrl: string | undefined;

const iconRefMapRetryDelay = 200;

type IconRefMapResponse = {
  version: string;
  icons: Record<string, string>;
};

function updateIconRefMap(url: string | undefined): void {
  if (!url) {
    return;
  }

  if (
    url === iconRefMapUrl &&
    (iconRefMapRequest || loadedIconRefMapUrl === url)
  ) {
    return;
  }

  iconRefMapUrl = url;
  const requestId = ++iconRefMapRequestId;
  const request = loadIconRefMap(url, requestId).finally(() => {
    if (requestId === iconRefMapRequestId) {
      iconRefMapRequest = undefined;
    }
  });
  iconRefMapRequest = request;
}

async function loadIconRefMap(url: string, requestId: number): Promise<void> {
  try {
    const expectedVersion = new URL(url, window.location.href).searchParams.get(
      'v',
    );
    while (requestId === iconRefMapRequestId) {
      const response = (await fetchRetry(url, { cache: 'no-store' })).json();
      const map = (await response) as IconRefMapResponse;
      if (requestId !== iconRefMapRequestId) {
        return;
      }
      if (map.version === expectedVersion) {
        loadedIconRefMapUrl = url;
        setIconRefMap(map.icons);
        store.set(gameDataAtom, (previous) => ({ ...previous }));
        return;
      }
      await new Promise((resolve) => setTimeout(resolve, iconRefMapRetryDelay));
    }
  } catch (error) {
    if (requestId === iconRefMapRequestId) {
      console.error(error);
    }
  }
}
