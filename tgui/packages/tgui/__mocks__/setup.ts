import './byond';

import { vi } from 'vitest';

vi.mock('../layouts', async () => {
  const { Layout, Pane, Window } = await import('./layouts');
  return { Layout, Pane, Window };
});

vi.mock('../logging', () => {
  const logger = {
    debug: () => {},
    error: () => {},
    info: () => {},
    log: () => {},
    warn: () => {},
  };
  return {
    createLogger: () => logger,
    logger,
  };
});
