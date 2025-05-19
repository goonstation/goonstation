/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const path = require('path');
const { defineConfig } = require('@rspack/cli');
const { rspack } = require('@rspack/core');

const createStats = (verbose) => ({
  assets: verbose,
  builtAt: verbose,
  cached: false,
  children: false,
  chunks: false,
  colors: true,
  entrypoints: true,
  hash: false,
  modules: false,
  performance: false,
  timings: verbose,
  version: verbose,
});

module.exports = (env = {}, argv) => {
  const mode = argv.mode || 'production';
  const bench = env.TGUI_BENCH;

  /** @type {import('@rspack/core').Configuration} */
  const config = defineConfig({
    cache: true,
    experiments: {
      cache: {
        type: 'persistent',
        storage: {
          type: 'filesystem',
          directory: path.resolve(__dirname, '.yarn/rspack'),
        },
      },
      css: true,
    },
    mode: mode === 'production' ? 'production' : 'development',
    context: path.resolve(__dirname),
    target: ['web', 'browserslist:edge >= 123'],
    entry: {
      tgui: ['./packages/tgui'],
      // 'tgui-panel': ['./packages/tgui-panel'], // |GOONSTATION-CHANGE| Not used by us yet
      // 'tgui-say': ['./packages/tgui-say'], // |GOONSTATION-CHANGE| Not used by us yet
    },
    output: {
      path: argv.useTmpFolder
        ? path.resolve(__dirname, '../browserassets/src/tgui/.tmp') // |GOONSTATION-CHANGE| ('./public/.tmp') -> ('../browserassets/src/tgui/.tmp')
        : path.resolve(__dirname, '../browserassets/src/tgui'), // |GOONSTATION-CHANGE| ('./public') -> ('../browserassets/src/tgui')
      filename: '[name].bundle.js',
      chunkFilename: '[name].bundle.js',
      chunkLoadTimeout: 15000,
      publicPath: '/',
      assetModuleFilename: '[name][ext]', // TODO: check
    },
    resolve: {
      pnp: true,
      extensions: ['.tsx', '.ts', '.js', '.jsx'],
      alias: {}, // |GOONSTATION-CHANGE| No aliases for us, as we don't bounce outside of tgui often (yet)
    },
    module: {
      rules: [
        {
          test: /\.([tj]s(x)?|cjs)$/,
          use: [
            {
              loader: 'builtin:swc-loader',
              options: {
                jsc: {
                  parser: {
                    syntax: 'typescript',
                    tsx: true,
                  },
                  transform: {
                    react: {
                      runtime: 'automatic',
                    },
                  },
                },
              },
            },
          ],
          type: 'javascript/auto',
        },
        {
          test: /\.(s)?css$/,
          use: [
            {
              loader: require.resolve('sass-loader'),
              options: {
                api: 'modern-compiler',
                implementation: 'sass-embedded',
              },
            },
          ],
          type: 'css',
        },
        {
          test: /\.(png|jpg)$/,
          use: [
            {
              loader: require.resolve('url-loader'),
              options: {
                esModule: false,
                outputPath: 'assets/', // [516 TODO]: resolve path?
                publicPath: '/assets/', // [516 TODO]: resolve path?
              },
            },
          ],
        },
        {
          test: /\.svg$/,
          oneOf: [
            {
              issuer: /\.(s)?css$/,
              type: 'asset/inline',
            },
            {
              use: [
                {
                  loader: require.resolve('url-loader'),
                  options: {
                    esModule: false,
                    outputPath: 'assets/', // [516 TODO]: resolve path?
                    publicPath: '/assets/', // [516 TODO]: resolve path?
                  },
                },
              ],
            },
          ],
        },
      ],
    },
    optimization: {
      emitOnErrors: false,
    },
    performance: {
      hints: false,
    },
    devtool: false,

    stats: createStats(true),
    plugins: [
      new rspack.EnvironmentPlugin({
        NODE_ENV: env.NODE_ENV || mode,
        WEBPACK_HMR_ENABLED: env.WEBPACK_HMR_ENABLED || argv.hot || false,
        DEV_SERVER_IP: env.DEV_SERVER_IP || null,
      }),
    ],
  });

  if (bench) {
    config.entry = {
      'tgui-bench': ['./packages/tgui-bench/entrypoint'],
    };
  }

  // [516 TODO]: minimizer config, or are defaults fine for production? Below is old webpack config
  // Production build specific options
  // if (mode === 'production') {
  //   const { EsbuildPlugin } = require('esbuild-loader');
  //   config.optimization.minimizer = [
  //     new EsbuildPlugin({
  //       target: 'edge123',
  //       css: true,
  //       legalComments: 'none', // We're open source, these are in the original source files
  //     }),
  //   ];
  // }

  // Development build specific options
  if (mode !== 'production') {
    config.devtool = 'cheap-module-source-map';
  }

  // Development server specific options
  if (argv.devServer) {
    config.devServer = {
      progress: false,
      quiet: false,
      noInfo: false,
      clientLogLevel: 'silent',
      stats: createStats(false),
    };
  }

  return config;
};
