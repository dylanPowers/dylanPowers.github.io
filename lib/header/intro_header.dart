library intro_header;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:about_me/element_style_measurer.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  static const String PANEL_EXPANDED = 'panel-expanded';
  static const String PANEL_CONDENSED = 'panel-condensed';
  static const String PANEL_HIDDEN = 'panel-hidden';
  static const String PANEL_DISPLAYED = 'panel-displayed';
  static const String NAME_COLLAPSED = 'name-collapsed';
  static const String NAME_EXPANDED = 'name-expanded';

  @observable String nameStyle = NAME_EXPANDED;
  @observable String panelDisplayStyle = PANEL_DISPLAYED;
  @observable String panelSizeStyle = PANEL_EXPANDED;
  @observable num panelYTranslation = 0;

  Timer _displayTimer = new Timer(Duration.ZERO, () {});
  Element _name;
  Interval _nameTopRange;
  Element _panel;
  Interval _panelHeightRange;
  StreamSubscription<EnhancedScrollEvent> _scrollHandler;

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
    var nameStyle = new TopStyleMeasurer(_name);
    _nameTopRange = nameStyle.measureClassRange(NAME_COLLAPSED, NAME_EXPANDED);
    var panelStyle = new HeightStyleMeasurer(_panel);
    _panelHeightRange = panelStyle.measureClassRange(PANEL_CONDENSED, PANEL_EXPANDED);
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
    panelSizeStyle = PANEL_CONDENSED;

    _displayTimer.cancel();
    _displayTimer = new Timer(new Duration(milliseconds: 500), () {
      _panel.style.transitionDuration = '150ms';
      if (panelYTranslation < _panelHeightRange.min / 2 &&
          window.pageYOffset > _panelHeightRange.max) {
        panelDisplayStyle = PANEL_HIDDEN;
      } else {
        panelDisplayStyle = PANEL_DISPLAYED;
      }
      panelYTranslation = 0;
    });

    // Goes last
    if (e.yMovement < 0) {
      _displayCollapsedPanel(e);
    } else if (e.yMovement > 0) {
      _hideCollapsedPanel(e);
    }
  }

  void _updatedExpandedPanel(EnhancedScrollEvent e) {
    panelDisplayStyle = PANEL_DISPLAYED;
    panelSizeStyle = PANEL_EXPANDED;
  }

  void _displayCollapsedPanel(EnhancedScrollEvent e) {
    num newTranslation = panelYTranslation - e.yMovement;
    if ((42 > newTranslation && newTranslation > 0) &&
        e.newYPosition > _panelHeightRange.min &&
        panelDisplayStyle != PANEL_DISPLAYED) {
      panelYTranslation = newTranslation;
    } else {
      panelYTranslation = 0;
      panelDisplayStyle = PANEL_DISPLAYED;
      _displayTimer.cancel();
    }
  }

  void _hideCollapsedPanel(EnhancedScrollEvent e) {
    if (panelDisplayStyle == PANEL_DISPLAYED) {
      panelYTranslation = _panelHeightRange.min;
    }

    panelDisplayStyle = PANEL_HIDDEN;

    num movement = _calcDownScrollMovement(e);

    if (movement < _panelHeightRange.min &&
        panelYTranslation - movement > 0) {
      panelYTranslation -= movement;
    } else {
      panelYTranslation = 0;
      _displayTimer.cancel();
    }
  }

  /**
   * Removes the panel height of the displayed panel vs the condensed panel from
   * the scrolling y movement. Kinda complex to explain in words, but there's a
   * portion of the header that in relation to the css style's is not hidden.
   * Instead it is "shrunk." This removes that shrink to condensed distance
   * from the scrolling y movement so that the point where the switch from
   * expanded to condensed acts a virtual point of 0.
   */
  num _calcDownScrollMovement(EnhancedScrollEvent e) {
    if (e.newYPosition - e.yMovement < _panelHeightRange.range) {
      return e.newYPosition - _panelHeightRange.range;
    } else {
      return e.yMovement;
    }
  }

  void _updateName(EnhancedScrollEvent e) {
    if (e.newYPosition > _nameTopRange.range) {
      nameStyle = NAME_COLLAPSED;
      _name.style.top = '';
      _name.style.transform = '';
    } else if (e.newYPosition > _nameTopRange.min) {
      nameStyle = NAME_COLLAPSED;
//      _name.style.top = '${_nameTopRange.max - e.newYPosition}px';
    } else {
      nameStyle = NAME_EXPANDED;
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
