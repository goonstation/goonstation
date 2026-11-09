import { globalEvents } from '../../global-events';

// --------- Handlers ------------------------------------------------------///

/**
 * |GOONSTATION-ADD| Byond skin macros forward mouse/ctrl state to us so
 * interfaces can react to input happening over the map.
 * Removed upstream in https://github.com/tgstation/tgstation/pull/90310
 */
export function mouseDown(): void {
  globalEvents.emit('byond/mousedown');
}

export function mouseUp(): void {
  globalEvents.emit('byond/mouseup');
}

export function ctrlDown(): void {
  globalEvents.emit('byond/ctrldown');
}

export function ctrlUp(): void {
  globalEvents.emit('byond/ctrlup');
}
