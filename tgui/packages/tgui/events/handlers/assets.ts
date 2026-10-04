import { loadMappings } from 'common/assets';
import { fetchRetry } from 'tgui-core/http';

import { loadedMappings } from '../../assets';
import { gameDataAtom, store } from '../store';

let iconRefMapUrl: string | undefined;
let iconRefMapRequest: Promise<void> | undefined;
let iconRefMapRequestId = 0;
let loadedIconRefMapUrl: string | undefined;

const iconRefMapRetryDelay = 200;

type IconRefMapResponse = {
  version: string;
  icons: typeof Byond.iconRefMap;
};

// --------- Handlers ------------------------------------------------------///

export function handleLoadAssets(payload: Record<string, string>): void {
  loadMappings(payload, loadedMappings);

  const nextIconRefMapUrl = payload['icon_ref_map.json'];
  if (!nextIconRefMapUrl) {
    return;
  }

  if (
    nextIconRefMapUrl === iconRefMapUrl &&
    (iconRefMapRequest || loadedIconRefMapUrl === nextIconRefMapUrl)
  ) {
    return;
  }

  iconRefMapUrl = nextIconRefMapUrl;
  const requestId = ++iconRefMapRequestId;
  const request = loadIconRefMap(nextIconRefMapUrl, requestId).finally(() => {
    if (requestId === iconRefMapRequestId) {
      iconRefMapRequest = undefined;
    }
  });
  iconRefMapRequest = request;
}

// --------- Helpers -------------------------------------------------------///

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

function setIconRefMap(map: typeof Byond.iconRefMap): void {
  Byond.iconRefMap = map;
  store.set(gameDataAtom, (previous) => ({ ...previous }));
}
