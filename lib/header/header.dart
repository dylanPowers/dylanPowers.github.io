library intro_header;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:about_me/css_style_props.dart';
import 'package:about_me/element_style_measurer.dart';
import 'package:about_me/enhanced_window_on_scroll.dart';
import 'package:paper_elements/paper_dropdown.dart';

part 'overflowed_links_menu.dart';

@CustomTag('dkp-header')
class HeaderElement extends PolymerElement {

  // Split up the email address to make the spammers actually have to run the code
  final String EMAIL_ADDRESS = 'dylan.kyle.powers';

  static const String NAME_CONDENSED = 'name-condensed';
  static const String NAME_EXPANDED = 'name-expanded';
  static const String PANEL_CONDENSED = 'panel-condensed';
  static const String PANEL_EXPANDED = 'panel-expanded';
  static const String PANEL_DISPLAYED = 'panel-displayed';
  static const String PANEL_HIDDEN = 'panel-hidden';
  static const String PIC_CONDENSED = 'pic-condensed';
  static const String PIC_EXPANDED = 'pic-expanded';

  @observable bool isOverflowedLinksMenuOpen = false;
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
  StreamSubscription _windowResizeHandler;

  factory HeaderElement() {
    return new Element.tag('dkp-header') as HeaderElement;
  }

  HeaderElement.created() : super.created();

  @override
  void attached() {
    super.attached();
    
    _name = shadowRoot.querySelector('#name');
    _panel = shadowRoot.querySelector('#panel');

    _headerLinks = shadowRoot.getElementById('links-box').querySelectorAll('header-link');

    _panelTop = new CssTopProp(_panel.style);
    _panelTransform = new CssTransformProp(_panel.style);
    _panelTransform.translateY = 0;
    _panelTransitionDuration = new CssTransitionDurationProp(_panel.style);

    _attachEventHandlers();
  }

  @override
  void detached() {
    super.detached();
    
    _scrollHandler.cancel();
    _windowResizeHandler.cancel();
  }

  void _adjustPartiallyViewablePanel() {
    _panelTop.top = -_condensedHeight + _panelTransform.translateY;
    _panelTransform.translateY = 0;

    if (window.pageYOffset > _expandedHeight &&
        -_panelTop.top >= _condensedHeight / 4) {
      panelDisplayStyle = PANEL_HIDDEN;
    } else {
      panelDisplayStyle = PANEL_DISPLAYED;
    }

    // Order matters here!
    _panelTransitionDuration.duration = new Duration(milliseconds: 150);
    _panelTop.clear();
  }

  void _attachEventHandlers() {
    _scrollHandler = new EnhancedWindowOnScroll(window).stream.listen(_updatePanel);
    _windowResizeHandler = window.onResize.listen((_) {
      _evaluateElRanges();
      _updateLinks();
      _updatePanel(new EnhancedScrollEvent.zeroMovement(window));
    });

    _evaluateElRanges();
    _updateLinks();
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
    Rectangle linkElDimensions;
    if (overflowedLinks.length == _headerLinks.length) {
      OverflowedLinksMenuElement leftMostLinkEl =
          shadowRoot.getElementsByTagName(OVERFLOWED_LINKS_MENU_TAG).first;
      linkElDimensions = leftMostLinkEl.buttonDimensions;
    } else {
      HtmlElement first = (_headerLinks.first as HtmlElement);
      HtmlElement leftMostLinkEl = first.shadowRoot.getElementById('link-logo-box');
      linkElDimensions = leftMostLinkEl.getBoundingClientRect();
    }

    const int numPixelsRightOfCenter = 160;
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
    // If the panel is displayed, that is we just started scrolling down, then
    // the y translation needs to be reset to a beginning value of the
    // condensed height.
    if (panelDisplayStyle == PANEL_DISPLAYED) {
      _panelTransform.translateY = _condensedHeight;
    }

    // When scrolling down, close the overflowed links menu
    isOverflowedLinksMenuOpen = false;

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
      _showTheLinksMenuButton();
    }

    for (int i = 0; i < numLinks && overflowedLinks.length < _headerLinks.length; ++i) {
      int linkIndex = _headerLinks.length - overflowedLinks.length - 1;
      HtmlElement link = _headerLinks[linkIndex];
      link.classes.add('hide');

      if (link.id == 'email') {
        // Glitch in the bindings
        link.setAttribute('user', '${EMAIL_ADDRESS}@gmail.com');
      }

      overflowedLinks.insert(0, new OverflowedHeaderLink(link));
    }
  }

  void _hideTheLinksMenuButton() {
    showLinksMenu = false;
    overflowedLinks.clear();
    (_headerLinks.last as HtmlElement).classes.remove('hide');
  }

  void _redisplayLinkIcons(int numLinks) {
    for (int i = 0; i < numLinks && overflowedLinks.length > 0; ++i) {
      overflowedLinks.removeAt(0);
      int linkIndex = _headerLinks.length - overflowedLinks.length - 1;
      HtmlElement link = _headerLinks[linkIndex];
      link.classes.remove('hide');
    }

    if (overflowedLinks.length <= 1) {
      _hideTheLinksMenuButton();
    }
  }

  void _showTheLinksMenuButton() {
    showLinksMenu = true;
    (_headerLinks.last as HtmlElement).classes.add('hide');
    overflowedLinks.add(new OverflowedHeaderLink(_headerLinks.last));
  }

  void _updateCondensedPanel(EnhancedScrollEvent e) {
    nameStyle = NAME_CONDENSED;
    panelSizeStyle = PANEL_CONDENSED;
    profilePicStyle = PIC_CONDENSED;

    _displayTimer = new Timer(new Duration(milliseconds: 500),
                               _adjustPartiallyViewablePanel);

    // Goes last
    if (e.yMovement < 0 || (e.yMovement == 0 && !_lastScrollDown)) {
      _displayCondensedPanel(e);
    } else if (e.yMovement > 0 || (e.yMovement == 0 && _lastScrollDown)) {
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
    } else if (e.yMovement < 0){
      _lastScrollDown = false;
    }
  }
}

class OverflowedHeaderLink {
  String href = "";
  String name = "";

  OverflowedHeaderLink(HtmlElement headerLink) {
    var url = headerLink.getAttribute('url');
    var user = headerLink.getAttribute('user');
    if (url != null && user != null) {
      href =  url + user;
    }

    var imgEl = headerLink.querySelector('img');
    if (imgEl != null) {
      name = imgEl.getAttribute('alt');
    }
  }
}
