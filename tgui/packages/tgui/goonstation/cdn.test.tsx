import { act, cleanup, render, screen } from '@testing-library/react';
import { Provider } from 'jotai';
import { memo } from 'react';
import { afterEach, describe, expect, it } from 'vitest';

import { configAtom, store } from '../events/store';
import type { Config } from '../events/types';
import { useResource } from './cdn';

const Asset = () => {
  const resource = useResource();

  return <div data-testid="src">{resource('images/antagTips/nuke-2.png')}</div>;
};

const MemoizedAsset = memo(Asset);

// Nothing re-renders this parent, so the asset url only tracks the cdn base if
// the hook subscribes. A `store.get()` read would pin the first resolution.
function Host() {
  return (
    <Provider store={store}>
      <MemoizedAsset />
    </Provider>
  );
}

const config = (cdn: string) => ({ cdn }) as Config;

describe('useResource', () => {
  afterEach(cleanup);

  it('falls back to the bare filename with no cdn base', () => {
    store.set(configAtom, config(''));
    render(<Host />);

    expect(screen.getByTestId('src').textContent).toBe('nuke-2.png');
  });

  it('re-resolves memoized consumers when the cdn base arrives late', () => {
    store.set(configAtom, config(''));
    render(<Host />);

    act(() => {
      store.set(configAtom, config('https://cdn.example.test/goon'));
    });

    expect(screen.getByTestId('src').textContent).toBe(
      'https://cdn.example.test/goon/images/antagTips/nuke-2.png',
    );
  });
});
