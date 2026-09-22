/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';

import { perf } from 'common/perf';
import { setupHotReloading } from 'tgui-dev-server/link/client.mjs';

import { App } from './App';
import { setDebugHotKeys } from './debug';
import { bus } from './events/listeners';
import { setupGlobalEvents } from './global-events';
import { setupHotKeys } from './hotkeys';
import { captureExternalLinks } from './links';
import { createRenderer } from './renderer';
import { createStackAugmentor } from './stack';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const renderApp = createRenderer(() => <App />);

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  window.__augmentStack__ = createStackAugmentor();

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  if (process.env.NODE_ENV !== 'production') {
    setDebugHotKeys();
  }

  // Dispatch incoming messages to their handlers
  Byond.subscribe((type, payload) => bus.dispatch({ type, payload }));

  renderApp();

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    // prettier-ignore
    module.hot.accept([
      './components',
      './layouts',
      './routes',
      './App',
    ], () => {
      renderApp();
    });
  }
}

setupApp();
