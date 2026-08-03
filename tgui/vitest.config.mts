import { defineConfig } from 'vitest/config';

export default defineConfig({
  // For misbehaving oxc
  oxc: {
    jsx: {
      runtime: 'automatic',
      importSource: 'react',
    },
  },
  test: {
    include: [
      'packages/**/__tests__/*.{ts,tsx}',
      'packages/**/*.{spec,test}.{ts,tsx}',
    ],
    exclude: ['packages/tgui-bench/**/*'],
    setupFiles: ['./packages/tgui/__mocks__/setup.ts'],
    environment: 'happy-dom',
    environmentOptions: {
      happyDOM: {
        settings: {
          navigation: {
            disableChildFrameNavigation: true,
          },
        },
      },
    },
    restoreMocks: true,
  },
});
