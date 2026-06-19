import { act, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import { Radio } from './index';

vi.mock('../../backend', () => ({
  useBackend: () => ({
    data: {
      name: 'Radio',
      frequency: 1459,
      lockedFrequency: 0,
      hasMicrophone: 0,
      hasSpeaker: 0,
      hasToggleButton: 0,
      microphoneEnabled: 0,
      speakerEnabled: 0,
      secureFrequencies: [],
      wires: 0,
      modifiable: 0,
      code: 0,
      sendButton: 0,
      power: 0,
    },
    act: vi.fn(),
  }),
  sendAct: vi.fn(),
}));

describe('Radio', () => {
  it('displays frequency correctly', () => {
    act(() => render(<Radio />));

    expect(screen.getByText('145.9')).toBeDefined();
  });
});
