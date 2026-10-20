import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import globals from 'globals';

export default [
  {
    ignores: [
      'node_modules/**',
      '**/*.bundle.*',
      '**/*.chunk.*',
      '**/*.hot-update.*',
      '**/*.min.js',
      '**/*.lock',
      '**/*.log',
      '**/*.json',
      '**/*.svg',
      '**/*.scss',
      '**/*.md',
      '**/*.css',
      '**/*.txt',
      '**/*.woff2',
      '**/*.eot',
      '**/*.ttf',
      'build/**',
      'gulp-hash-filename/**',
      '.eslintignore',
      '.eslintrc.*',
      'src/js/go.js',
      'src/js/telescope.js',
      'src/js/browserOutput.js',
      'src/js/processScheduler.js',
      'src/js/runtimeViewer.js',
      'src/js/stationNameChanger.js',
      'src/vendor/**',
    ],
  },
  js.configs.recommended,
  {
    files: ['src/**/*.{js,cjs,ts,tsx}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.node,
        BYOND: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': [
        'error',
        {
          argsIgnorePattern: '^_|^e$|^size$|^id$|^varArgs$',
          caughtErrorsIgnorePattern: '^_|^err$|^error$',
        },
      ],
    },
  },
  {
    files: ['gulpfile.js', '*.config.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
      },
    },
  },
  prettier,
];
