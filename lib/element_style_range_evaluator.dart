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
  
  Interval evalHeight(String minClass, String maxClass) {
    num min = _evaluateElHeight(minClass, maxClass);
    num max = _evaluateElHeight(maxClass, minClass);
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

  int _evaluateElHeight(String className, String conflictingClass) {
    var oldClasses = _el.className;
    var oldHeight = _el.style.height;

    _el.style.height = '';
    _el.classes.remove(conflictingClass);
    _el.classes.add(className);
    int height = _el.clientHeight;

    _el.className = oldClasses;
    _el.style.height = oldHeight;

    return height;
  }
}

class Interval {
  num min = 0;
  num max = 0;
  num get range => max - min;
  Interval(this.min, this.max);
}