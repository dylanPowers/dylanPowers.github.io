library about_me_tests;

import 'dart:async';
import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:unittest/html_individual_config.dart';
import 'package:about_me/header/intro_header.dart';
import 'package:polymer/polymer.dart';

part 'header_tests.dart';

void main() {
  initPolymer();
  useHtmlIndividualConfiguration();

  // It's good to get a new animation frame
  beforeEach(() => window.animationFrame);

  HeaderTests.run();
}