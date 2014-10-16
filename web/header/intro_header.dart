import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  static const String _PANEL_EXPANDED = 'panel-expanded';
  static const String _PANEL_COLLAPSED = 'panel-collapsed';
  static const String _NAME_COLLAPSED = 'name-collapsed';
  static const String _NAME_EXPANDED = 'name-expanded';

  @observable String panelStyle = _PANEL_EXPANDED;
  @observable String nameStyle = _NAME_EXPANDED;

  StreamSubscription<EnhancedScrollEvent> _scrollHandler;

  IntegerRange _panelHeightRange;
  IntegerRange _nameTopRange;
  Element _name;
  Element _panel;

  IntroHeaderElement.created() : super.created();

  @override
  void attached() {
    _name = shadowRoot.querySelector('#name');
    _panel = shadowRoot.querySelector('#panel');

    window.onResize.listen((_) {
      _evaluateElRanges();
    });

    _scrollHandler = EnhancedWindowOnScroll.stream.listen(_updateForScrollEvent);
    _evaluateElRanges();
  }

  void _evaluateElRanges() {
    _nameTopRange = _evaluateElementTopRange(_name, _NAME_COLLAPSED, _NAME_EXPANDED);
    _panelHeightRange = _evaluateElementHeightRange(_panel, _PANEL_COLLAPSED, _PANEL_EXPANDED);
  }

  static IntegerRange _evaluateElementHeightRange(Element el, String minClass, String maxClass) {
    var heightRange = new IntegerRange();

    heightRange.min = _evaluateElHeight(el, minClass, maxClass);
    heightRange.max = _evaluateElHeight(el, maxClass, minClass);

    return heightRange;
  }

  static int _evaluateElHeight(Element el, String className, String conflictingClass) {
    var oldClasses = el.className;
    var oldHeight = el.style.height;

    el.style.height = '';
    el.classes.remove(conflictingClass);
    el.classes.add(className);
    int height = el.clientHeight;

    el.className = oldClasses;
    el.style.height = oldHeight;

    return height;
  }

  static IntegerRange _evaluateElementTopRange(Element el, String minClass, String maxClass) {
    var topRange = new IntegerRange();

    topRange.min = _evaluateElTop(el, minClass, maxClass);
    topRange.max = _evaluateElTop(el, maxClass, minClass);

    return topRange;
  }

  static int _evaluateElTop(Element el, String className, String conflictingClass) {
    var oldClasses = el.className;
    var oldTop = el.style.top;

    el.style.top = '';
    el.classes.remove(conflictingClass);
    el.classes.add(className);
    int top = el.offsetTop;

    el.className = oldClasses;
    el.style.top = oldTop;

    return top;
  }

  void _updateForScrollEvent(EnhancedScrollEvent e) {
    _updateName(e);
    _updatePanel(e);
  }

  void _updatePanel(EnhancedScrollEvent e) {
    if (e.newYPosition > _panelHeightRange.range) {
      if (e.yMovement < 0) {
        panelStyle = _PANEL_COLLAPSED;
        _panel.style.height = '';
        _panel.style.top = '';
      } else {
        _panel.style.top = '${0 - _panelHeightRange.min}px';
      }
    } else if (e.newYPosition > 0) {
      _panel.style.height = '${_panelHeightRange.max - e.newYPosition}px';
    } else {
      panelStyle = _PANEL_EXPANDED;
      _panel.style.height = '';
    }
  }

  void _updateName(EnhancedScrollEvent e) {
    if (e.newYPosition > _nameTopRange.range) {
      nameStyle = _NAME_COLLAPSED;
      _name.style.top = '';
      _name.style.transform = '';
    } else if (e.newYPosition > _nameTopRange.min) {
      _name.style.top = '${_nameTopRange.max - e.newYPosition}px';
    } else {
      nameStyle = _NAME_EXPANDED;
      _name.style.top = '';
      _name.style.transform = '';
    }
  }
}

class EnhancedScrollSink extends EventSink<Event> {
  int _lastScrollX = 0;
  int _lastScrollY = 0;
  final EventSink<EnhancedScrollEvent> _outputSink;

  EnhancedScrollSink(this._outputSink);

  void add(Event data) {
    var scrollE = new EnhancedScrollEvent(_lastScrollX, _lastScrollY,
                                          window.pageXOffset, window.pageYOffset);
    _lastScrollX = scrollE.newXPosition;
    _lastScrollY = scrollE.newYPosition;

    _outputSink.add(scrollE);
  }

  void addError(e, [stackTrace]) => _outputSink.addError(e, stackTrace);
  void close() => _outputSink.close();
}

abstract class EnhancedWindowOnScroll {

  static Stream<EnhancedScrollEvent> _singleton;

  static Stream<EnhancedScrollEvent> get stream {
    if (_singleton == null) {
      _singleton = new Stream<EnhancedScrollEvent>.eventTransformed(window.onScroll,
                                                                    _mapSink);
    }

    return _singleton;
  }

  static EventSink _mapSink(EventSink<EnhancedScrollEvent> sink) {
    return new EnhancedScrollSink(sink);
  }
}


class EnhancedScrollEvent {
  final int oldXPosition;
  final int oldYPosition;
  final int newXPosition;
  final int newYPosition;
  int get xMovement => newXPosition - oldXPosition;
  int get yMovement => newYPosition - oldYPosition;

  EnhancedScrollEvent(this.oldXPosition, this.oldYPosition,
                      this.newXPosition, this.newYPosition);
}

class IntegerRange {
  int min;
  int max;
  int get range => max - min;
}
