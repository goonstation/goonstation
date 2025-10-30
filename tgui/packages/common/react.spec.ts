import { describe, it } from 'vitest';

/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */
import { classes } from './react';

describe('classes', () => {
  it('empty', ({ expect }) => {
    expect(classes([])).toBe('');
  });

  it('result contains inputs', ({ expect }) => {
    const output = classes(['foo', 'bar', false, true, 0, 1, 'baz']);
    expect(output).toContain('foo');
    expect(output).toContain('bar');
    expect(output).toContain('baz');
  });
});
