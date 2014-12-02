library css_style_props_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:about_me/css_style_props.dart';

void run() {
  describe('Transform property constructor', () {
    it('can read a translateY value', () {
      var testEl = new Element.div();
      testEl.style.transform = 'translateY(1px)';
      expect(new CssTransformProp(testEl.style).translateY).toEqual(1);
    });
  });
}