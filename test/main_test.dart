library about_me_tests;

import 'dart:async';
import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:about_me/header/intro_header.dart';
import 'package:about_me/element_style_range_evaluator.dart';
import 'package:polymer/polymer.dart';

part 'element_style_range_evaluator_tests.dart';
part 'header_tests.dart';

void main() {
  initPolymer();
  useHtmlEnhancedConfiguration();

  // It's good to get a new animation frame
  beforeEach(() => window.animationFrame);

  HeaderTests.run();
  runElementStyleRangeEvaluatorTests();
}