import { describe, it } from 'vitest';

import { getGasColor, getGasFromId, getGasLabel } from './constants';

describe('gas helper functions', () => {
  it('should get the proper gas label', ({ expect }) => {
    const gasId = 'n2o';
    const gasLabel = getGasLabel(gasId);
    expect(gasLabel).toBe('N₂O');
  });

  it('should get the proper gas label with a fallback', ({ expect }) => {
    const gasId = 'nonexistent';
    const gasLabel = getGasLabel(gasId, 'fallback');

    expect(gasLabel).toBe('fallback');
  });

  it('should return none if no gas and no fallback is found', ({ expect }) => {
    const gasId = 'nonexistent';
    const gasLabel = getGasLabel(gasId);

    expect(gasLabel).toBe('None');
  });

  it('should get the proper gas color', ({ expect }) => {
    const gasId = 'n2';
    const gasColor = getGasColor(gasId);

    expect(gasColor).toBe('red');
  });

  it('should return a string if no gas is found', ({ expect }) => {
    const gasId = 'nonexistent';
    const gasColor = getGasColor(gasId);

    expect(gasColor).toBe('black');
  });

  it('should return the gas object if found', ({ expect }) => {
    const gasId = 'n2o';
    const gas = getGasFromId(gasId);

    expect(gas).toEqual({
      id: 'n2o',
      name: 'Nitrous Oxide',
      label: 'N₂O',
      color: 'red',
    });
  });

  it('should return undefined if no gas is found', ({ expect }) => {
    const gasId = 'nonexistent';
    const gas = getGasFromId(gasId);

    expect(gas).toBeUndefined();
  });
});
