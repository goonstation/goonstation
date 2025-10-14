/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';

import { perf } from 'common/perf';
import { setupHotReloading } from 'tgui-dev-server/link/client.mjs';

import { setGlobalStore } from './backend';
import { setupGlobalEvents } from './events';
import { setupHotKeys } from './hotkeys';
import { loadIconRefMap } from './icons';
import { captureExternalLinks } from './links';
import { createRenderer } from './renderer';
import { configureStore } from './store';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore();

const renderApp = createRenderer(() => {
  setGlobalStore(store);
  loadIconRefMap();

  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent(store);
  return <Component />;
});

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // Re-render UI on store updates
  store.subscribe(renderApp);

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    // prettier-ignore
    module.hot.accept([
      './components',
      './debug',
      './layouts',
      './routes',
    ], () => {
      renderApp();
    });
  }
}

setupApp();
