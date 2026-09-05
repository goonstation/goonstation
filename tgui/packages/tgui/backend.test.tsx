import { act, cleanup, render, screen } from '@testing-library/react';
import { Provider } from 'jotai';
import { memo } from 'react';
import { afterEach, describe, expect, it } from 'vitest';

import { useBackend, useSharedState } from './backend';
import { gameDataAtom, sharedAtom, store } from './events/store';

type Data = { counter: number };

const DataReader = () => {
  const { data } = useBackend<Data>();

  return <div data-testid="counter">{data.counter}</div>;
};

const SharedReader = () => {
  const [value] = useSharedState('label', 'initial');

  return <div data-testid="label">{value}</div>;
};

const MemoizedData = memo(DataReader);
const MemoizedShared = memo(SharedReader);

// Memoized consumers need their own subscription.
function Host() {
  return (
    <Provider store={store}>
      <MemoizedData />
      <MemoizedShared />
    </Provider>
  );
}

describe('backend hooks', () => {
  afterEach(cleanup);

  it('updates memoized consumers when backend data changes', () => {
    store.set(gameDataAtom, { counter: 1 });
    render(<Host />);

    expect(screen.getByTestId('counter').textContent).toBe('1');

    act(() => {
      store.set(gameDataAtom, { counter: 2 });
    });

    expect(screen.getByTestId('counter').textContent).toBe('2');
  });

  it('updates memoized consumers when shared state changes', () => {
    store.set(sharedAtom, {});
    render(<Host />);

    expect(screen.getByTestId('label').textContent).toBe('initial');

    act(() => {
      store.set(sharedAtom, { label: 'pushed' });
    });

    expect(screen.getByTestId('label').textContent).toBe('pushed');
  });
});
