import { loadStyleSheet } from 'common/assets';
import { EventBus } from 'tgui-core/eventbus';

import { handleLoadAssets } from './handlers/assets';
import {
  acknowledgePayloadChunk,
  oversizePayloadResponse,
} from './handlers/chunking';
import { ctrlDown, ctrlUp, mouseDown, mouseUp } from './handlers/mouse';
import { ping } from './handlers/ping';
import { secretId } from './handlers/secret';
import { suspend } from './handlers/suspense';
import { update } from './handlers/update';

/**
 * A string/handler map.
 * Ideally, these reference a function named after the respective event type.
 */
const listeners = {
  // Assets
  'asset/mappings': handleLoadAssets,
  'asset/stylesheet': loadStyleSheet,
  // Standard window events
  ping,
  suspend,
  update,
  // Chunking
  oversizePayloadResponse,
  acknowledgePayloadChunk,
  // |GOONSTATION-ADD| Secret interfaces
  'backend/secret-id': secretId,
  // |GOONSTATION-ADD| Byond skin macro forwarding
  'byond/ctrldown': ctrlDown,
  'byond/ctrlup': ctrlUp,
  'byond/mousedown': mouseDown,
  'byond/mouseup': mouseUp,
} as const;

export const bus = new EventBus(listeners);
