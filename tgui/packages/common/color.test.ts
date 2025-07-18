import { describe, it } from 'vitest';

import { Color } from './color';

describe('Color', () => {
  it('should create a color with default values', ({ expect }) => {
    const color = new Color();
    expect(color.r).toBe(0);
    expect(color.g).toBe(0);
    expect(color.b).toBe(0);
    expect(color.a).toBe(1);
  });

  it('should create a color from hex', ({ expect }) => {
    const color = Color.fromHex('#ff0000');
    expect(color.r).toBe(255);
    expect(color.g).toBe(0);
    expect(color.b).toBe(0);
  });

  it('should darken a color', ({ expect }) => {
    const color = new Color(100, 100, 100).darken(50);
    expect(color.r).toBe(50);
    expect(color.g).toBe(50);
    expect(color.b).toBe(50);
  });

  it('should lighten a color', ({ expect }) => {
    const color = new Color(100, 100, 100).lighten(50);
    expect(color.r).toBe(150);
    expect(color.g).toBe(150);
    expect(color.b).toBe(150);
  });

  it('should interpolate between two colors', ({ expect }) => {
    const color1 = new Color(0, 0, 0);
    const color2 = new Color(100, 100, 100);
    const color = Color.lerp(color1, color2, 0.5);
    expect(color.r).toBe(50);
    expect(color.g).toBe(50);
    expect(color.b).toBe(50);
  });

  it('should lookup a color in an array', ({ expect }) => {
    const colors = [new Color(0, 0, 0), new Color(100, 100, 100)];
    const color = Color.lookup(0.5, colors);
    expect(color.r).toBe(50);
    expect(color.g).toBe(50);
    expect(color.b).toBe(50);
  });
});
