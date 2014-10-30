library about_me_tests;

import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
//import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:about_me/header/intro_header.dart';
import '../web/main.dart';

part 'header_tests.dart';

void main() {
//  initPolymer();
  setUp(() {
    setUpInjector();
    module((Module m) => m.install(new AboutMeNGApp()));
  });
  tearDown(tearDownInjector);
  
  HeaderTests.run();
}