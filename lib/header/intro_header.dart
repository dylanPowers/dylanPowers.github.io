library intro_header;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:about_me/css_style_props.dart';
import 'package:about_me/element_style_measurer.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  static const String NAME_CONDENSED = 'name-condensed';
  static const String NAME_EXPANDED = 'name-expanded';
  static const String PANEL_CONDENSED = 'panel-condensed';
  static const String PANEL_EXPANDED = 'panel-expanded';
  static const String PANEL_DISPLAYED = 'panel-displayed';
  static const String PANEL_HIDDEN = 'panel-hidden';
  static const String PIC_CONDENSED = 'pic-condensed';
  static const String PIC_EXPANDED = 'pic-expanded';

  @observable String nameStyle = NAME_EXPANDED;
  final overflowedLinks = new ObservableList<OverflowedHeaderLink>();
  @observable String panelDisplayStyle = PANEL_DISPLAYED;
  @observable String panelSizeStyle = PANEL_EXPANDED;
  @observable String profilePicStyle = PIC_EXPANDED;
  @observable bool showLinksMenu = false;

  num get _condensedHeight => _panelHeights.min;
  Timer _displayTimer = new Timer(Duration.ZERO, () {});
  num get _expandedHeight => _panelHeights.max;
  ElementList _headerLinks;
  bool _lastScrollDown = true;
  Element _name;
  Interval _nameTopInterval;
  Element _panel;
  Interval _panelHeights;
  CssTopProp _panelTop;
  CssTransformProp _panelTransform;
  CssTransitionDurationProp _panelTransitionDuration;
  StreamSubscription<EnhancedScrollEvent> _scrollHandler;

  factory IntroHeaderElement() {
    return new Element.tag('intro-header') as IntroHeaderElement;
  }

  IntroHeaderElement.created() : super.created();

  @override
  void attached() {
    _name = shadowRoot.querySelector('#name');
    _panel = shadowRoot.querySelector('#panel');

    _headerLinks = shadowRoot.getElementById('links-box').querySelectorAll('header-link');

    _panelTop = new CssTopProp(_panel.style);
    _panelTransform = new CssTransformProp(_panel.style);
    _panelTransform.translateY = 0;
    _panelTransitionDuration = new CssTransitionDurationProp(_panel.style);

    window.onResize.listen((_) {
      _evaluateElRanges();
      _updateLinks();
    });

    _scrollHandler = EnhancedWindowOnScroll.stream.listen(_updateForScrollEvent);
    _evaluateElRanges();
    _updateLinks();
  }

  @override
  void detached() {
    _scrollHandler.cancel();
  }

  void _adjustPartiallyViewablePanel() {
    _panelTop.top = -_condensedHeight + _panelTransform.translateY;
    _panelTransform.translateY = 0;

    if (window.pageYOffset > _expandedHeight &&
        -_panelTop.top >= _condensedHeight / 4 &&
        window.pageYOffset > _expandedHeight) {
      panelDisplayStyle = PANEL_HIDDEN;
    } else {
      panelDisplayStyle = PANEL_DISPLAYED;
    }

    // Order matters here!
    _panelTransitionDuration.duration = new Duration(milliseconds: 150);
    _panelTop.clear();
  }

  /**
   * Kinda complex to explain in words, but when
   * scrolling down, a large scroll jump over the expanded mode to condensed
   * mode transition can cause a problem where the condensed panel
   * is "scrolled" too far.
   * This recalculates the scroll movement so that it is relative to that
   * transition point.
   */
  num _calcCondensedScrollMovement(EnhancedScrollEvent e) {
    if (e.newYPosition - e.yMovement < _panelHeights.range) {
      return e.newYPosition - _panelHeights.range;
    } else {
      return e.yMovement;
    }
  }

  void _clearPanelTimers() {
    _panelTransitionDuration.clear();
    _displayTimer.cancel();
  }

  void _displayCondensedPanel(EnhancedScrollEvent e) {
    num newTranslation = _panelTransform.translateY - e.yMovement;
    if ((_condensedHeight > newTranslation && newTranslation > 0) &&
         e.newYPosition > _condensedHeight &&
         panelDisplayStyle != PANEL_DISPLAYED) {
      _panelTransform.translateY = newTranslation;
    } else {
      _panelTransform.translateY = 0;
      panelDisplayStyle = PANEL_DISPLAYED;
     _clearPanelTimers();
    }
  }

  void _evaluateElRanges() {
    var nameStyle = new TopStyleMeasurer(_name);
    _nameTopInterval = nameStyle.measureClassRange(NAME_CONDENSED, NAME_EXPANDED);
    var panelStyle = new HeightStyleMeasurer(_panel);
    _panelHeights = panelStyle.measureClassRange(PANEL_CONDENSED, PANEL_EXPANDED);
  }

  void _hideCondensedPanel(EnhancedScrollEvent e) {
    if (panelDisplayStyle == PANEL_DISPLAYED) {
      _panelTransform.translateY = _condensedHeight;
    }

    panelDisplayStyle = PANEL_HIDDEN;
    num condensedMove = _calcCondensedScrollMovement(e);
    if (condensedMove < _condensedHeight &&
        _panelTransform.translateY - condensedMove > 0) {
      _panelTransform.translateY -= condensedMove;
    } else {
      _panelTransform.translateY = 0;
      _clearPanelTimers();
    }
  }

  void _updateCondensedPanel(EnhancedScrollEvent e) {
    nameStyle = NAME_CONDENSED;
    panelSizeStyle = PANEL_CONDENSED;
    profilePicStyle = PIC_CONDENSED;

    _displayTimer = new Timer(new Duration(milliseconds: 500),
                               _adjustPartiallyViewablePanel);

    // Goes last
    if (e.yMovement < 0) {
      _displayCondensedPanel(e);
    } else if (e.yMovement > 0) {
      _hideCondensedPanel(e);
    }
  }

  void _updateExpandedPanel(EnhancedScrollEvent e) {
    _panelTransform.translateY = 0;
    panelDisplayStyle = PANEL_DISPLAYED;
    nameStyle = NAME_EXPANDED;
    panelSizeStyle = PANEL_EXPANDED;
    profilePicStyle = PIC_EXPANDED;
  }

  void _updateLinks() {
    HtmlElement twoToLast = _headerLinks[_headerLinks.length - 2];
    HtmlElement last = _headerLinks.last;
    if (window.document.body.clientWidth < 1000) {
      showLinksMenu = true;
      overflowedLinks.add(new OverflowedHeaderLink(twoToLast));
      twoToLast.classes.add('hide');
      overflowedLinks.add(new OverflowedHeaderLink(last));
      last.classes.add('hide');
    } else {
      showLinksMenu = false;
      overflowedLinks.clear();
      twoToLast.classes.remove('hide');
      last.classes.remove('hide');
    }
  }

  void _updateForScrollEvent(EnhancedScrollEvent e) {
    _updatePanel(e);
  }

  void _updatePanel(EnhancedScrollEvent e) {
    _clearPanelTimers();

    if (e.newYPosition > _panelHeights.range) {
      _updateCondensedPanel(e);
    } else {
      _updateExpandedPanel(e);
    }

    if (e.yMovement > 0) {
      _lastScrollDown = true;
    } else {
      _lastScrollDown = false;
    }
  }
}

class OverflowedHeaderLink {
  String name;
  String href;

  OverflowedHeaderLink(HtmlElement headerLink) {
    href = headerLink.getAttribute('href');
    var imgEl = headerLink.querySelector('img');
    if (imgEl != null) {
      name = imgEl.getAttribute('alt');
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
