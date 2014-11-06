import 'dart:html';

class ElementStyleRangeEvaluator {
  final Element _el;
  ElementStyleRangeEvaluator(this._el);

  Interval evalTop(String minClass, String maxClass) {
    return new Interval();
  }
}

class Interval {
  num min = 0;
  num max = 0;
  num get range => max - min;
}