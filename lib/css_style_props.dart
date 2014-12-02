library css_style_props;

import 'dart:html';

abstract class CssProperty {
  final CssStyleDeclaration style;
  String get text => style.transform;

  CssProperty(this.style);

  void clear();
  String toString() => text;

  void _regenStyleText();
}

class CssTopProp extends CssProperty {
  num get top => _top;
      set top(newTop) {
    if (newTop != _top) {
      _top = newTop;
      _regenStyleText();
    }
  }
  num _top = double.NAN;

  CssTopProp(CssStyleDeclaration style) : super(style);

  @override
  void clear() => top = double.NAN;

  @override
  void _regenStyleText() {
    style.top = !_top.isNaN ? '${top}px' : '';
  }
}

class CssTransformProp extends CssProperty {
  num get translateY => _translateY;
      set translateY(yTranslation) {
    if (yTranslation != _translateY) {
      _translateY = yTranslation;
      _regenStyleText();
    }
  }
  num _translateY = double.NAN;

  CssTransformProp(CssStyleDeclaration style) : super(style);

  void clear() => translateY = double.NAN;

  @override
  void _regenStyleText() {
    String translateYString = '';
    if (!_translateY.isNaN) {
      translateYString = 'translateY(${_translateY}px)';
    }

    style.transform = translateYString;
  }
}

class CssTransitionDurationProp extends CssProperty {
  Duration get duration => _duration != null ? _duration : Duration.ZERO;
           set duration(newDuration) {
    if (_duration != newDuration) {
      _duration = newDuration;
      _regenStyleText();
    }
  }
  Duration _duration;

  CssTransitionDurationProp(CssStyleDeclaration style) : super(style);

  @override
  void clear() => duration = null;

  @override
  void _regenStyleText() {
    style.transitionDuration = '';
    if (_duration != null) {
      style.transitionDuration = '${_duration.inMilliseconds}ms';
    }
  }
}