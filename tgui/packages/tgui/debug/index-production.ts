/**
 * @file
 * @copyright 2025 ZeWaka
 * @license MIT
 */

// These are production stubs for everything in index.ts

export const useDebug = () => ({
  debugLayout: false,
  kitchenSink: false,
  setDebugLayout: () => {},
  toggleKitchenSink: () => {},
});

export const KitchenSink = null;

export const debugMiddleware = () => (next) => (action) => next(action);
export const relayMiddleware = () => (next) => (action) => next(action);

export const debugReducer = (state = {}) => state;

export const toggleKitchenSink = () => ({});
export const toggleDebugLayout = () => ({});
export const openExternalBrowser = () => ({});
