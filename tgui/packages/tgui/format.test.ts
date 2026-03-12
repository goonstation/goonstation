import { describe, it } from 'vitest';

import {
  formatDb,
  formatMoney,
  formatSiBaseTenUnit,
  formatSiUnit,
  formatTime,
} from './format';

describe('formatSiUnit', () => {
  it('formats base values correctly', ({ expect }) => {
    const value = 100;
    const result = formatSiUnit(value);
    expect(result).toBe('100');
  });

  it('formats kilo values correctly', ({ expect }) => {
    const value = 1500;
    const result = formatSiUnit(value);
    expect(result).toBe('1.50 k');
  });

  it('formats micro values correctly', ({ expect }) => {
    const value = 0.0001;
    const result = formatSiUnit(value);
    expect(result).toBe('100 μ');
  });

  it('formats values with custom units correctly', ({ expect }) => {
    const value = 0.5;
    const result = formatSiUnit(value, 0, 'Hz');
    expect(result).toBe('0.50 Hz');
  });

  it('handles non-finite values correctly', ({ expect }) => {
    const value = Infinity;
    const result = formatSiUnit(value);
    expect(result).toBe('Infinity');
  });
});

describe('formatMoney', () => {
  it('formats integer values with default precision', ({ expect }) => {
    const value = 1234567;
    const result = formatMoney(value);
    expect(result).toBe('1\u2009234\u2009567');
  });

  it('formats float values with specified precision', ({ expect }) => {
    const value = 1234567.89;
    const result = formatMoney(value, 2);
    expect(result).toBe('1\u2009234\u2009567.89');
  });

  it('formats negative values correctly', ({ expect }) => {
    const value = -1234567.89;
    const result = formatMoney(value, 2);
    expect(result).toBe('-1\u2009234\u2009567.89');
  });

  it('returns non-finite values as is', ({ expect }) => {
    const value = Infinity;
    const result = formatMoney(value);
    expect(result).toBe('Infinity');
  });

  it('formats zero correctly', ({ expect }) => {
    const value = 0;
    const result = formatMoney(value);
    expect(result).toBe('0');
  });
});

describe('formatDb', () => {
  it('formats positive values correctly', ({ expect }) => {
    const value = 1;
    const result = formatDb(value);
    expect(result).toBe('+0.00 dB');
  });

  it('formats negative values correctly', ({ expect }) => {
    const value = 0.5;
    const result = formatDb(value);
    expect(result).toBe('-6.02 dB');
  });

  it('formats Infinity correctly', ({ expect }) => {
    const value = 0;
    const result = formatDb(value);
    expect(result).toBe('-Inf dB');
  });

  it('formats very large values correctly', ({ expect }) => {
    const value = 1e6;
    const result = formatDb(value);
    expect(result).toBe('+120.00 dB');
  });

  it('formats very small values correctly', ({ expect }) => {
    const value = 1e-6;
    const result = formatDb(value);
    expect(result).toBe('-120.00 dB');
  });
});

describe('formatSiBaseTenUnit', () => {
  it('formats SI base 10 units', ({ expect }) => {
    expect(formatSiBaseTenUnit(1e9)).toBe('1.00 · 10⁹');
    expect(formatSiBaseTenUnit(1234567890, 0, 'm')).toBe('1.23 · 10⁹ m');
  });
});

describe('formatTime', () => {
  // |GOONSTATION-CHANGE|
  it('formats time values', ({ expect }) => {
    expect(formatTime(36000)).toBe('60:00');
    expect(formatTime(36001)).toBe('60:00'); // over an hour maxes out at 60 minutes
    expect(formatTime(12530)).toBe('20:53');
  });
});
