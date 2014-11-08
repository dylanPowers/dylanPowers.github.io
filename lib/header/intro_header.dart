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
    var nameStyle = new ElementStyleRangeEvaluator(_name);
    _nameTopRange = nameStyle.evalTop(_NAME_COLLAPSED, _NAME_EXPANDED);
    var panelStyle = new ElementStyleRangeEvaluator(_panel);
    _panelHeightRange = panelStyle.evalHeight(_PANEL_COLLAPSED, _PANEL_EXPANDED);
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

    if (e.yMovement > 0) {
      _lastScrollDown = true;
    } else {
      _lastScrollDown = false;
    }
  }

  bool _lastScrollDown = true;
  void _updateCollapsedPanel(EnhancedScrollEvent e) {
    panelSizeStyle = _PANEL_COLLAPSED;
    
    if (e.yMovement < 0 || e.newYPosition <= _panelHeightRange.max) {
      _displayCollapsedPanel(e);
    } else if (e.yMovement > 0 && e.newYPosition > _panelHeightRange.max) {
      if (!_lastScrollDown && panelDisplayStyle == _PANEL_DISPLAYED) {
        panelYTranslation = _panel.clientHeight;
      }

      panelDisplayStyle = _PANEL_HIDDEN;
      if (e.yMovement < _panel.clientHeight && panelYTranslation - e.yMovement > 0) {
        panelYTranslation -= e.yMovement;
      } else {
        panelYTranslation = 0;
      }
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
    num newTranslation = panelYTranslation - e.yMovement;
    if ((42 > newTranslation && newTranslation > 0) &&
        e.newYPosition > _panelHeightRange.max &&
        panelDisplayStyle != _PANEL_DISPLAYED) {
      panelYTranslation = newTranslation;
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
