library about_me_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'header_tests.dart';
import 'element_style_measurer_tests.dart';


void main() {
  initPolymer();
  useHtmlEnhancedConfiguration();

  // It's good to get a new animation frame
  beforeEach(() => window.animationFrame);

  runHeaderTests();
  runElementStyleMeasurerTests();
}