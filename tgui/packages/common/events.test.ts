import { describe, it, vi } from 'vitest';

import { EventEmitter } from './events';

describe('EventEmitter', () => {
  it('should add and trigger an event listener', ({ expect }) => {
    const emitter = new EventEmitter();
    const mockListener = vi.fn();
    emitter.on('test', mockListener);
    emitter.emit('test', 'payload');
    expect(mockListener).toHaveBeenCalledWith('payload');
  });

  it('should remove an event listener', ({ expect }) => {
    const emitter = new EventEmitter();
    const mockListener = vi.fn();
    emitter.on('test', mockListener);
    emitter.off('test', mockListener);
    emitter.emit('test', 'payload');
    expect(mockListener).not.toHaveBeenCalled();
  });

  it('should not fail when emitting an event with no listeners', ({
    expect,
  }) => {
    const emitter = new EventEmitter();
    expect(() => emitter.emit('test', 'payload')).not.toThrow();
  });

  it('should clear all event listeners', ({ expect }) => {
    const emitter = new EventEmitter();
    const mockListener = vi.fn();
    emitter.on('test', mockListener);
    emitter.clear();
    emitter.emit('test', 'payload');
    expect(mockListener).not.toHaveBeenCalled();
  });
});
