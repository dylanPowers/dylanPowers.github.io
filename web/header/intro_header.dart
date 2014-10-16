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

  int _minHeight;
  int _maxHeight;
  NumberSpan _nameTopRange;
  Element _name;
  Element _panel;


  IntroHeaderElement.created() : super.created();

  @override
  void attached() {
    _name = shadowRoot.querySelector('#name');
    _panel = shadowRoot.querySelector('#panel');

    window.onResize.listen((_) {
      _nameTopRange = _evaluateElementTop(_name, _NAME_COLLAPSED, _NAME_EXPANDED);
      _evaluateSize();
    });

    _scrollHandler = EnhancedWindowOnScroll.stream.listen(_updateForScrollEvent);

    _nameTopRange = _evaluateElementTop(_name, _NAME_COLLAPSED, _NAME_EXPANDED);
    _evaluateSize();
  }

  void _evaluateSize() {
    var oldClassName = _panel.className;
    var oldHeight = _panel.style.height;

    _panel.style.height = '';
    _panel.className = _PANEL_COLLAPSED;
    _minHeight = _panel.clientHeight;
    _panel.className = _PANEL_EXPANDED;
    _maxHeight = _panel.clientHeight;

    _panel.className = oldClassName;
    _panel.style.height = oldHeight;
  }

  NumberSpan _evaluateElementTop(Element el, String minClass, String maxClass) {
    var topRange = new NumberSpan();
    var oldClasses = el.className;
    var oldTop = el.style.top;

    el.style.height = '';
    el.classes.remove(maxClass);
    el.classes.add(minClass);
    topRange.min = el.offsetTop;
    el.classes.remove(minClass);
    el.classes.add(maxClass);
    topRange.max = el.offsetTop;

    el.className = oldClasses;
    el.style.top = oldTop;

    return topRange;
  }

  void _updateForScrollEvent(EnhancedScrollEvent e) {
    _updateName(e);
    _updatePanel(e);
  }

  void _updatePanel(EnhancedScrollEvent e) {
    if (e.newYPosition > _maxHeight - _minHeight) {
      if (e.yMovement < 0) {
        panelStyle = _PANEL_COLLAPSED;
        _panel.style.height = '';
      } else {
        _panel.style.height = '0px';
      }
    } else if (e.newYPosition > 0) {
      _panel.style.height = '${_maxHeight - e.newYPosition}px';
      _name.style.transform = 'scale(${(_maxHeight - _minHeight) / (e.newYPosition + (_maxHeight - _minHeight))}';
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

class NumberSpan {
  num min;
  num max;
  num get range => max - min;
}
