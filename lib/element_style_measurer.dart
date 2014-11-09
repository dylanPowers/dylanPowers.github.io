library element_style_measurer;

import 'dart:html';

class TopStyleMeasurer extends ElStyleMeasurerBase {
  String get oldStyleAttr => el.style.top;
         set oldStyleAttr(String top) => el.style.top = top;
  num _measure() => el.offsetTop;
  
  TopStyleMeasurer(Element el) : super(el);
}

class HeightStyleMeasurer extends ElStyleMeasurerBase {
  String get oldStyleAttr => el.style.height;
         set oldStyleAttr(String height) => el.style.height = height;
  num _measure() => el.clientHeight;
  
  HeightStyleMeasurer(Element el) : super(el);
}

abstract class ElStyleMeasurerBase {
  String get oldStyleAttr;
         set oldStyleAttr(String);
  num _measure();
  
  final Element el;
  ElStyleMeasurerBase(this.el);
  
  Interval measureClassRange(String minClass, String maxClass) {
    num min = measureClass(minClass, maxClass);
    num max = measureClass(maxClass, minClass);
    return new Interval(min, max);
  }
  
  num measureClass(String className, String conflictingClass) {
    var oldClasses = el.className;
    var oldElStyle = oldStyleAttr;
    var oldTransitionDuration = el.style.transitionDuration;

    oldStyleAttr = '';
    el.style.transitionDuration = '0';
    el.classes.remove(conflictingClass);
    el.classes.add(className);
    num measurement = _measure();

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