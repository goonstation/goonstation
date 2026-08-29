import { perf } from 'common/perf';
import type { BooleanLike } from 'tgui-core/react';

import { setupDrag } from '../../drag';
import { logger } from '../../logging';
import { resumeRenderer } from '../../renderer';
import {
  configAtom,
  gameDataAtom,
  gameStaticDataAtom,
  sharedAtom,
  store,
  suspendedAtom,
} from '../store';
import type { Config } from '../types';

// --------- Handlers ------------------------------------------------------///

type UpdatePayload = {
  config?: Config;
  data?: Record<string, unknown>;
  shared?: Record<string, string>;
  static_data?: Record<string, unknown>;
};

export function update(payload: UpdatePayload): void {
  updateFancy(payload);

  if (store.get(suspendedAtom)) {
    resume(payload);
    store.set(suspendedAtom, false);
  }

  updateData(payload);
}

// --------- Helpers -------------------------------------------------------///

let fancyState: BooleanLike | undefined;

/** Byond has to be told when the window stops drawing its own titlebar */
function updateFancy(payload: UpdatePayload): void {
  const fancy = payload.config?.window?.fancy;

  // Initialize fancy state
  if (fancyState === undefined) {
    fancyState = fancy;
    return;
  }

  // React to changes in fancy
  if (fancyState !== fancy) {
    logger.log('changing fancy mode to', fancy);
    fancyState = fancy;
    Byond.winset(Byond.windowId, {
      titlebar: !fancy,
      'can-resize': !fancy,
    });
  }
}

/** Resumes the tgui window if suspended */
function resume(payload: UpdatePayload): void {
  // Show the payload
  logger.log('Resuming:', payload);
  // Signal renderer that we have resumed
  resumeRenderer();
  // Setup drag
  setupDrag();
  // We schedule this for the next tick here because resizing and unhiding
  // during the same tick will flash with a white background.
  setTimeout(() => {
    perf.mark('resume/start');
    // Doublecheck if we are not re-suspended.
    if (store.get(suspendedAtom)) {
      return;
    }
    perf.mark('resume/finish');

    if (process.env.NODE_ENV !== 'production') {
      logger.log('visible in', perf.measure('render/finish', 'resume/finish'));
    }
  });
}

/** Delegates update data to the appropriate store */
function updateData(payload: UpdatePayload): void {
  if (payload.config) {
    store.set(configAtom, (prev) => ({
      ...prev,
      ...payload.config,
    }));
  }

  if (payload.static_data) {
    store.set(gameStaticDataAtom, (prev) => ({
      ...prev,
      ...payload.static_data,
    }));
  }

  if (payload.data) {
    store.set(gameDataAtom, (prev) => ({
      ...prev,
      ...payload.data,
    }));
  }

  if (payload.shared) {
    const newShared: Record<string, unknown> = {};

    for (const key in payload.shared) {
      const value = payload.shared[key];
      if (value === '') {
        newShared[key] = undefined;
      } else {
        newShared[key] = JSON.parse(value);
      }
    }

    store.set(sharedAtom, (prev) => ({
      ...prev,
      ...newShared,
    }));
  }
}
