const path = require('path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const libraryRoot = path.resolve(__dirname, '..');

const config = {
  watchFolders: [libraryRoot],
  resolver: {
    nodeModulesPaths: [
      path.resolve(__dirname, 'node_modules'),
    ],
    // Ensure the library's source is resolved from the parent dir
    extraNodeModules: {
      'react-native-nswindow': libraryRoot,
    },
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
