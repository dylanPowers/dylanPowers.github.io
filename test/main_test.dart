library about_me_tests;

import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
//import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:about_me/header/intro_header.dart';
import 'package:about_me/enhanced_window_on_scroll.dart';
import '../web/main.dart';

part 'header_tests.dart';
part 'enhanced_window_scroll_test.dart';

void main() {
  setUp(() {
    setUpInjector();
    module((Module m) => m.install(new AboutMeNGApp()));
  });
  tearDown(tearDownInjector);
  
  HeaderTests.run();
  EnhancedWindowScrollTests.run();
}

Future loadTemplate(String template) {
  return HttpRequest.request(template).then((HttpRequest r) {
      inject((TemplateCache cache) => 
        cache.put(template, new HttpResponse(r.status, r.responseText)));
  });
}

//void compileComponent(String html){
//  async(inject((TestBed tb) {
//    final s = tb.rootScope.createChild(scope);
//    final el = tb.compile(html);
//
//    microLeap();
//    tb.rootScope.apply();
//
//    callback(el);
//  }));
//}