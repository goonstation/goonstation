import { loadMappings } from 'common/assets';
import { fetchRetry } from 'tgui-core/http';

import { loadedMappings } from '../../assets';

// --------- Handlers ------------------------------------------------------///

export function handleLoadAssets(payload: Record<string, string>): void {
  loadMappings(payload, loadedMappings);

  if (
    'icon_ref_map.json' in payload &&
    Object.keys(Byond.iconRefMap).length === 0
  ) {
    fetchRetry(payload['icon_ref_map.json'])
      .then((res) => res.json())
      .then(setIconRefMap)
      .catch(console.error);
  }
}

// --------- Helpers -------------------------------------------------------///

function setIconRefMap(map: Record<string, string>): void {
  Byond.iconRefMap = map;
}
