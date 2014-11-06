library element_style_range_evaluator;

import 'dart:html';

class ElementStyleRangeEvaluator {
  final Element _el;
  ElementStyleRangeEvaluator(this._el);

  Interval evalTop(String minClass, String maxClass) {
    num min = _evaluateElTop(minClass, maxClass);
    num max = _evaluateElTop(maxClass, minClass);
    return new Interval(min, max);
  }

  num _evaluateElTop(String className, String conflictingClass) {
    var oldClasses = _el.className;
    var oldTop = _el.style.top;

    _el.style.top = '';
    _el.classes.remove(conflictingClass);
    _el.classes.add(className);
    num top = _el.offsetTop;

    _el.className = oldClasses;
    _el.style.top = oldTop;

    return top;
  }
}

class Interval {
  num min = 0;
  num max = 0;
  num get range => max - min;
  Interval(this.min, this.max);
}