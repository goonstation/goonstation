## Vitest

You can now write and run unit tests in tgui.

It's quite simple: create a file ending in `.test.ts` or `.spec.ts` (usually with the same filename as the file you're testing), and create a test case:

```js
test('something', () => {
  expect('a').toBe('a');
});
```

Refer to [README](../README.md) to learn how to run tests.

There is an example test in `packages/common/react.spec.ts`.

You can read more about Vitest here: https://vitest.dev/

### Interfaces

You can also test ingame interfaces. See `tgui\packages\tgui\interfaces\Radio\Radio.test.tsx` for an example.
