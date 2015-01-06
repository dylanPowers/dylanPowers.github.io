library about_me_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'header/header_tests.dart' as headerTests;
import 'element_style_measurer_tests.dart';
import 'css_style_props_tests.dart' as cssStylePropsTests;


void main() {
  initPolymer();
  useHtmlEnhancedConfiguration();

  // It's good to get a new animation frame to prevent randomness
  beforeEach(() => window.animationFrame);

  headerTests.run();
  runElementStyleMeasurerTests();
  cssStylePropsTests.run();
}