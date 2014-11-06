import 'dart:html';

class ElementStyleRangeEvaluator {
  final Element _el;
  ElementStyleRangeEvaluator(this._el);

  Interval evalTop(String minClass, String maxClass) {

  }
}

class Interval {
  num min;
  num max;
  num get range => max - min;
}