import { useRef } from 'react';

export const useConstant = <T>(fn: () => T) => {
  const ref = useRef<{ value: T }>();
  if (!ref.current) {
    ref.current = { value: fn() };
  }
  return ref.current.value;
};
