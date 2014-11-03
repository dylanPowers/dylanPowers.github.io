library intro_header;

import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:about_me/enhanced_window_on_scroll.dart';

@Component(
    selector: 'intro-header',
    cssUrl: 'intro_header.css',
    templateUrl: 'intro_header.html')
class IntroHeaderElement implements ShadowRootAware {
  static const String _PANEL_EXPANDED = 'panel-expanded';
  static const String _PANEL_COLLAPSED = 'panel-collapsed';
  static const String _PANEL_HIDDEN = 'panel-hidden';
  static const String _PANEL_DISPLAYED = 'panel-displayed';
  static const String _NAME_COLLAPSED = 'name-collapsed';
  static const String _NAME_EXPANDED = 'name-expanded';

//  Scope scope;
  @NgOneWay('panelStyle') String panelStyle = _PANEL_EXPANDED;
  @NgOneWay('panelDisplayStyle') String panelDisplayStyle = _PANEL_DISPLAYED;
  @NgOneWay('nameStyle') String nameStyle = _NAME_EXPANDED;

  StreamSubscription<EnhancedScrollEvent> _scrollHandler;
  final Stream<EnhancedScrollEvent> _scrollStream;

  IntegerRange _panelHeightRange;
  IntegerRange _nameTopRange;
  Element _name;
  Element _panel;
  Window _win = window;
  
  IntroHeaderElement(EnhancedWindowOnScroll onScroll) : 
      _scrollStream = onScroll.stream;
  
  @override
  void onShadowRoot(ShadowRoot shadowRoot) {
    
    _name = shadowRoot.querySelector('#name');
    _panel = shadowRoot.querySelector('#panel');

    _win.onResize.listen((_) {
      _evaluateElRanges();
    });

    _scrollHandler = _scrollStream.listen(_updateForScrollEvent);
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
      panelStyle = _PANEL_COLLAPSED;
      _panel.style.transform = '';
      if (e.yMovement < -10 || e.newYPosition <= _panelHeightRange.max) {
        panelDisplayStyle = _PANEL_DISPLAYED;
      } else if (e.yMovement > 0 && e.newYPosition > _panelHeightRange.max) {
        panelDisplayStyle = _PANEL_HIDDEN;
      }
    } else {
      panelDisplayStyle = _PANEL_DISPLAYED;
      panelStyle = _PANEL_EXPANDED;
      if (e.newYPosition > 0) {
        _panel.style.transform = 'translateY(-${e.newYPosition}px)';
      } else {
        _panel.style.transform = '';
      }
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


class IntegerRange {
  int min;
  int max;
  int get range => max - min;
}
