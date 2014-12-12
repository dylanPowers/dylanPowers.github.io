library intro_header;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:about_me/css_style_props.dart';
import 'package:about_me/element_style_measurer.dart';
import 'package:about_me/enhanced_window_on_scroll.dart';

@CustomTag('dkp-header')
class HeaderElement extends PolymerElement {
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

  factory HeaderElement() {
    return new Element.tag('dkp-header') as HeaderElement;
  }

  HeaderElement.created() : super.created();

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

    _scrollHandler = new EnhancedWindowOnScroll(window).stream.listen(_updatePanel);
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

  /**
   * Calculates the number of header-links (the icons visible on the header panel)
   * to hide. A negative value means that an absolute value of that many
   * header-links should be redisplayed.
   */
  int _calcNumLinksToHide() {
    HtmlElement leftMostLinkEl;
    if (overflowedLinks.length == _headerLinks.length) {
      leftMostLinkEl = shadowRoot.getElementById('links-menu-button');
    } else {
      HtmlElement first = (_headerLinks.first as HtmlElement);
      leftMostLinkEl = first.shadowRoot.getElementById('link-logo-box');
    }

    const int numPixelsRightOfCenter = 160;
    var linkElDimensions = leftMostLinkEl.getBoundingClientRect();
    var body = (window.document as HtmlDocument).body;
    var noMansLand = body.clientWidth / 2 + numPixelsRightOfCenter;
    double exactNumLinks = (noMansLand - linkElDimensions.left) / linkElDimensions.width;
    return exactNumLinks.ceil();
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

  void _hideLinkIcons(int numLinks) {
    if (overflowedLinks.length == 0) {
      showLinksMenu = true;
      (_headerLinks.last as HtmlElement).classes.add('hide');
      overflowedLinks.add(new OverflowedHeaderLink(_headerLinks.last));
    }

    for (int i = 0; i < numLinks && overflowedLinks.length < _headerLinks.length; ++i) {
      int linkIndex = _headerLinks.length - overflowedLinks.length - 1;
      HtmlElement link = _headerLinks[linkIndex];
      link.classes.add('hide');
      overflowedLinks.insert(0, new OverflowedHeaderLink(link));
    }
  }

  void _redisplayLinkIcons(int numLinks) {
    for (int i = 0; i < numLinks && overflowedLinks.length > 0; ++i) {
      overflowedLinks.removeAt(0);
      int linkIndex = _headerLinks.length - overflowedLinks.length - 1;
      HtmlElement link = _headerLinks[linkIndex];
      link.classes.remove('hide');
    }

    if (overflowedLinks.length <= 1) {
      showLinksMenu = false;
      overflowedLinks.clear();
      (_headerLinks.last as HtmlElement).classes.remove('hide');
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
    int numLinksToHide = _calcNumLinksToHide();
    if (numLinksToHide < 0) {
      _redisplayLinkIcons(-numLinksToHide);
    } else if (numLinksToHide > 0) {
      _hideLinkIcons(numLinksToHide);
    }
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