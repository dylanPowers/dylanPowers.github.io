library intro_header;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:about_me/element_style_range_evaluator.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  static const String _PANEL_EXPANDED = 'panel-expanded';
  static const String _PANEL_COLLAPSED = 'panel-collapsed';
  static const String _PANEL_HIDDEN = 'panel-hidden';
  static const String _PANEL_DISPLAYED = 'panel-displayed';
  static const String _NAME_COLLAPSED = 'name-collapsed';
  static const String _NAME_EXPANDED = 'name-expanded';

  @observable String nameStyle = _NAME_EXPANDED;
  @observable String panelDisplayStyle = _PANEL_DISPLAYED;
  @observable String panelSizeStyle = _PANEL_EXPANDED;
  @observable num panelYTranslation = 0;

  StreamSubscription<EnhancedScrollEvent> _scrollHandler;

  Interval _panelHeightRange;
  Interval _nameTopRange;
  Element _name;
  Element _panel;

  factory IntroHeaderElement() {
    return new Element.tag('intro-header') as IntroHeaderElement;
  }

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

  static Interval _evaluateElementHeightRange(Element el, String minClass, String maxClass) {
    num min = _evaluateElHeight(el, minClass, maxClass);
    num max = _evaluateElHeight(el, maxClass, minClass);

    return new Interval(min, max);
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

  static Interval _evaluateElementTopRange(Element el, String minClass, String maxClass) {
    num min = _evaluateElTop(el, minClass, maxClass);
    num max = _evaluateElTop(el, maxClass, minClass);

    return new Interval(min, max);
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
      _updateCollapsedPanel(e);
    } else {
      _updatedExpandedPanel(e);
    }
  }

  void _updateCollapsedPanel(EnhancedScrollEvent e) {
    panelSizeStyle = _PANEL_COLLAPSED;
    if (e.yMovement < 0 || e.newYPosition <= _panelHeightRange.max) {
      _displayCollapsedPanel(e);
    } else if (e.yMovement > 0 && e.newYPosition > _panelHeightRange.max) {
      panelYTranslation = 0;
      panelDisplayStyle = _PANEL_HIDDEN;
    }
  }

  void _updatedExpandedPanel(EnhancedScrollEvent e) {
    panelDisplayStyle = _PANEL_DISPLAYED;
    panelSizeStyle = _PANEL_EXPANDED;
    if (e.newYPosition > 0) {
      panelYTranslation = -e.newYPosition;
    } else {
      panelYTranslation = 0;
    }
  }

  void _displayCollapsedPanel(EnhancedScrollEvent e) {
    if (-42 < e.yMovement && e.yMovement < 0 && e.newYPosition > _panelHeightRange.max) {
      panelYTranslation -= e.yMovement;
    } else {
      panelYTranslation = 0;
      panelDisplayStyle = _PANEL_DISPLAYED;
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
