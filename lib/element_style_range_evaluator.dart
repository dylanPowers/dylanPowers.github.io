library element_style_range_evaluator;

import 'dart:html';

class ElementStyleRangeEvaluator {
  final Element _el;
  ElementStyleRangeEvaluator(this._el);

  Interval evalTop(String minClass, String maxClass) {
    var int = new Interval(5, 5);
    return int;
  }
}

class Interval {
  num min = 0;
  num max = 0;
  num get range => max - min;
  Interval(this.min, this.max);
}