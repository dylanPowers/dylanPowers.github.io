module.exports = function(config) {
  config.set({
    basePath: '.',
    frameworks: ['dart-unittest'],

    // list of files / patterns to load in the browser
    files: [
      {pattern: 'packages/browser/dart.js', watched: false, included: true, served: true},
      {pattern: 'lib/header/intro_header.html', included: true, served: true},
      {pattern: '**/*.dart', watched: true, included: false, served: true},
      {pattern: '**/*.css', watched: true, included: false, served: true},
      {pattern: '**/*.html', watched: true, included: false, served: true},
      {pattern: 'test/main_test.dart', watched: true, included: true },
    ],

    autoWatch: true,

    plugins: [
      'karma-dart',
      //'karma-chrome-launcher'
    ]
  });
};