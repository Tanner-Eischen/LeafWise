/**
 * Babel Configuration for LeafWise React Native Application
 * Configures JavaScript/TypeScript transformation for development and testing
 */

module.exports = function (api) {
  api.cache(true);
  
  return {
    presets: [
      'babel-preset-expo',
    ],
    plugins: [
      // Module resolver for absolute imports
      [
        'module-resolver',
        {
          root: ['./src'],
          alias: {
            '@': './src',
            '@config': './config',
            '@assets': './assets',
            '@tests': './tests',
          },
        },
      ],
    ],
    env: {
      test: {
        presets: [
          ['babel-preset-expo', { jsxRuntime: 'automatic' }],
        ],
      },
    },
  };
};