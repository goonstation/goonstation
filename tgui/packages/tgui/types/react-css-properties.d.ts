// Allow CSS custom properties in React style props.
// eslint-disable-next-line react/no-typos
import 'react'; // module augmentation

declare module 'react' {
  interface CSSProperties {
    // | undefined in case you want to do `{ '--my-var': maybeUndefinedVariable }`
    [key: `--${string}`]: string | number | undefined;
  }
}
