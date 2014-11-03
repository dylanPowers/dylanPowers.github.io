library about_me_tests;

import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
import 'package:guinness/guinness_html.dart';
import 'package:about_me/header/intro_header.dart';
import 'package:about_me/enhanced_window_on_scroll.dart';
import '../web/main.dart';

part 'header_tests.dart';
part 'enhanced_window_scroll_test.dart';

void main() {
  guinnessEnableHtmlMatchers();

  beforeEach(() {
    setUpInjector();
    module((Module m) => m.install(new AboutMeNGApp()));
  });
  afterEach(tearDownInjector);
  
  HeaderTests.run();
  EnhancedWindowScrollTests.run();
}

Future<Element> loadNCompileTemplate(String templateUrl, String htmlComponent) {
  return _loadTemplate(templateUrl).then((_) => _compileComponent(htmlComponent));
}

Element _compileComponent(String htmlComponent) {
  Element el;
  inject((TestBed tb) {
    async(() {
      el = tb.compile(htmlComponent);
      microLeap();
    }).call();
    tb.rootScope.apply();
  });
  return el;
}

Future _loadTemplate(String template) {
  return HttpRequest.request(template).then((HttpRequest r) {
    inject((TemplateCache cache) =>
    cache.put(template, new HttpResponse(r.status, r.responseText)));
  });
}
