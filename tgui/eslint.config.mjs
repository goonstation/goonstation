import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { FlatCompat } from '@eslint/eslintrc';
import js from '@eslint/js';
import tsParser from '@typescript-eslint/parser';
import { defineConfig, globalIgnores } from 'eslint/config';
import react from 'eslint-plugin-react';
import simpleImportSort from 'eslint-plugin-simple-import-sort';
import sonarjs from 'eslint-plugin-sonarjs';
import unusedImports from 'eslint-plugin-unused-imports';
import globals from 'globals';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default defineConfig([
  globalIgnores([
    '.yarn/**/*',
    '**/node_modules',
    '**/*.bundle.*',
    '**/*.chunk.*',
    '**/*.hot-update.*',
    '**/**.lock',
    '**/**.log',
    '**/**.json',
    '**/**.svg',
    '**/**.scss',
    '**/**.md',
    '**/**.css',
    '**/**.txt',
    '**/**.woff2',
    '**/**.ttf',
  ]),
  sonarjs.configs.recommended,
  {
    extends: compat.extends('prettier'),

    plugins: {
      react,
      'unused-imports': unusedImports,
      'simple-import-sort': simpleImportSort,
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },

      parser: tsParser,
      ecmaVersion: 2023,
      sourceType: 'module',

      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
    },

    settings: {
      react: {
        version: '19.1',
      },
    },

    rules: {
      'no-async-promise-executor': 'error',
      'no-cond-assign': 'error',
      'no-debugger': 'error',
      'no-dupe-args': 'error',
      'no-dupe-keys': 'error',
      'no-duplicate-case': 'error',
      'no-empty-character-class': 'error',
      'no-ex-assign': 'error',
      'no-extra-boolean-cast': 'error',
      'no-extra-semi': 'error',
      'no-func-assign': 'error',
      'no-import-assign': 'error',
      'no-inner-declarations': 'error',
      'no-invalid-regexp': 'error',
      'no-irregular-whitespace': 'error',
      'no-misleading-character-class': 'error',
      'no-obj-calls': 'error',
      'no-prototype-builtins': 'error',
      'no-regex-spaces': 'error',
      'no-sparse-arrays': 'error',
      'no-template-curly-in-string': 'error',
      'no-unexpected-multiline': 'error',
      'no-unsafe-finally': 'error',
      'no-unsafe-negation': 'error',
      'use-isnan': 'error',
      'valid-typeof': 'error',

      complexity: [
        'error',
        {
          max: 50,
        },
      ],

      curly: ['error', 'multi-line'],
      'dot-location': ['error', 'property'],
      eqeqeq: ['error', 'always'],
      'no-case-declarations': 'error',
      'no-empty-pattern': 'error',
      'no-fallthrough': 'error',
      'no-global-assign': 'error',
      'no-multi-spaces': 'warn',
      'no-octal': 'error',
      'no-octal-escape': 'error',
      'no-redeclare': 'error',
      'no-return-assign': 'error',
      'no-self-assign': 'error',
      'no-sequences': 'error',
      'no-unused-labels': 'warn',
      'no-useless-escape': 'warn',
      'no-with': 'error',
      radix: 'error',
      strict: 'error',
      'no-delete-var': 'error',
      'no-shadow-restricted-names': 'error',
      'no-undef-init': 'error',
      'array-bracket-newline': ['error', 'consistent'],
      'array-bracket-spacing': ['error', 'never'],
      'block-spacing': ['error', 'always'],

      'comma-dangle': [
        'error',
        {
          arrays: 'always-multiline',
          objects: 'always-multiline',
          imports: 'always-multiline',
          exports: 'always-multiline',
          functions: 'only-multiline',
        },
      ],

      'comma-spacing': [
        'error',
        {
          before: false,
          after: true,
        },
      ],

      'comma-style': ['error', 'last'],
      'computed-property-spacing': ['error', 'never'],
      'func-call-spacing': ['error', 'never'],
      'object-curly-spacing': ['error', 'always'],
      semi: 'error',

      'semi-spacing': [
        'error',
        {
          before: false,
          after: true,
        },
      ],

      'semi-style': ['error', 'last'],
      'space-before-blocks': ['error', 'always'],
      'space-in-parens': ['error', 'never'],
      'spaced-comment': ['error', 'always'],

      'switch-colon-spacing': [
        'error',
        {
          before: false,
          after: true,
        },
      ],

      'template-tag-spacing': ['error', 'never'],

      'arrow-spacing': [
        'error',
        {
          before: true,
          after: true,
        },
      ],

      'generator-star-spacing': [
        'error',
        {
          before: false,
          after: true,
        },
      ],

      'no-class-assign': 'error',
      'no-const-assign': 'error',
      'no-dupe-class-members': 'error',
      'no-new-symbol': 'error',
      'no-this-before-super': 'error',
      'no-var': 'error',
      'prefer-arrow-callback': 'error',

      'yield-star-spacing': [
        'error',
        {
          before: false,
          after: true,
        },
      ],

      'sonarjs/pseudo-random': 'off',
      'sonarjs/todo-tag': 'off',
      'sonarjs/no-unused-vars': 'off',
      'sonarjs/slow-regex': 'off',
      'sonarjs/no-labels': 'off',
      'sonarjs/label-position': 'off',
      // Too much work to fix this right now
      'sonarjs/cognitive-complexity': ['error', 70], // 50
      'sonarjs/updated-loop-counter': 'off',
      'sonarjs/no-nested-assignment': 'off',
      'sonarjs/no-nested-functions': 'off',
      'sonarjs/no-ignored-exceptions': 'off',
      'sonarjs/single-char-in-character-classes': 'off',
      'sonarjs/concise-regex': 'off',
      'sonarjs/no-inverted-boolean-check': 'off',
      'sonarjs/table-header': 'off',
      'sonarjs/no-small-switch': 'off',
      'sonarjs/duplicates-in-character-class': 'off',
      'sonarjs/anchor-precedence': 'off',
      'sonarjs/regex-complexity': 'off',
      'sonarjs/no-empty-test-file': 'off',
      'sonarjs/assertions-in-tests': 'off',
      'sonarjs/empty-string-repetition': 'off',
      'sonarjs/prefer-single-boolean-return': 'off',
      'sonarjs/no-nested-template-literals': 'off',
      'sonarjs/no-dead-store': 'off',
      'sonarjs/no-nested-conditional': 'off',
      'sonarjs/no-commented-code': 'off',

      'react/boolean-prop-naming': 'error',
      'react/button-has-type': 'error',
      'react/default-props-match-prop-types': 'error',
      'react/no-access-state-in-setstate': 'error',
      'react/no-children-prop': 'error',
      'react/no-danger': 'error',
      'react/no-danger-with-children': 'error',
      'react/no-deprecated': 'error',
      'react/no-did-mount-set-state': 'error',
      'react/no-did-update-set-state': 'error',
      'react/no-direct-mutation-state': 'error',
      'react/no-find-dom-node': 'error',
      'react/no-is-mounted': 'error',
      'react/no-redundant-should-component-update': 'error',
      'react/no-render-return-value': 'error',
      'react/no-typos': 'error',
      'react/no-string-refs': 'error',
      'react/no-this-in-sfc': 'error',
      'react/no-unescaped-entities': 'error',
      'react/no-unsafe': 'error',
      'react/no-unused-prop-types': 'error',
      'react/no-unused-state': 'error',
      'react/no-will-update-set-state': 'error',
      'react/prefer-es6-class': 'error',
      'react/prefer-read-only-props': 'off',
      'react/prefer-stateless-function': 'error',
      'react/require-render-return': 'error',
      'react/self-closing-comp': 'error',
      'react/style-prop-object': 'error',
      'react/void-dom-elements-no-children': 'error',
      'react/jsx-boolean-value': 'error',
      'react/jsx-closing-tag-location': 'error',
      'react/jsx-curly-spacing': 'error',
      'react/jsx-equals-spacing': 'error',
      'react/jsx-handler-names': 'error',
      'react/jsx-key': 'error',

      'react/jsx-max-depth': [
        'error',
        {
          max: 10,
        },
      ],

      'react/jsx-no-comment-textnodes': 'error',
      'react/jsx-no-duplicate-props': 'error',
      'react/jsx-no-target-blank': 'error',
      'react/jsx-no-undef': 'error',
      'react/jsx-no-useless-fragment': 'error',
      'react/jsx-fragments': 'error',
      'react/jsx-pascal-case': 'error',
      'react/jsx-props-no-multi-spaces': 'error',
      'react/jsx-tag-spacing': 'error',
      'react/jsx-uses-react': 'error',
      'react/jsx-uses-vars': 'error',
      'react/jsx-wrap-multilines': 'error',
      'unused-imports/no-unused-imports': 'error',
      'simple-import-sort/imports': 'error',
      'simple-import-sort/exports': 'error',
    },
  },
]);
