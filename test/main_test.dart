library about_me_tests;

import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:about_me/header/intro_header.dart';
import 'package:polymer/polymer.dart';

part 'header_tests.dart';

void main() {
  initPolymer();
  useHtmlConfiguration();

  HeaderTests.run();
}