library element_style_range_evaluator;

import 'dart:html';

class ElementStyleRangeEvaluator {
  final Element _el;
  ElementStyleRangeEvaluator(this._el);

  Interval evalTop(String minClass, String maxClass) {
    return new _TopStyleRange(_el).calcRange(minClass, maxClass);
  }
  
  Interval evalHeight(String minClass, String maxClass) {
    return new _HeightStyleRange(_el).calcRange(minClass, maxClass);
  }
}

class _TopStyleRange extends _ElStyleRangeEvalBase {
  String get oldStyleAttr => el.style.top;
         set oldStyleAttr(String top) => el.style.top = top;
  num measure() => el.offsetTop;
  
  _TopStyleRange(Element el) : super(el);
}

class _HeightStyleRange extends _ElStyleRangeEvalBase {
  String get oldStyleAttr => el.style.height;
         set oldStyleAttr(String height) => el.style.height = height;
  num measure() => el.clientHeight;
  
  _HeightStyleRange(Element el) : super(el);
}

abstract class _ElStyleRangeEvalBase {
  String get oldStyleAttr;
         set oldStyleAttr(String);
  num measure();
  
  final Element el;
  _ElStyleRangeEvalBase(this.el);
  
  Interval calcRange(String minClass, String maxClass) {
    num min = _eval(minClass, maxClass);
    num max = _eval(maxClass, minClass);
    return new Interval(min, max);
  }
  
  num _eval(String className, String conflictingClass) {
    var oldClasses = el.className;
    var oldElStyle = oldStyleAttr;
    var oldTransitionDuration = el.style.transitionDuration;

    oldStyleAttr = '';
    el.style.transitionDuration = '0';
    el.classes.remove(conflictingClass);
    el.classes.add(className);
    num measurement = measure();

    el.className = oldClasses;
    el.style.transitionDuration = oldTransitionDuration;
    oldStyleAttr = oldElStyle;

    return measurement;
  }
}

class Interval {
  num min = 0;
  num max = 0;
  num get range => max - min;
  Interval(this.min, this.max);
}