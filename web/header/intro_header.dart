import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  static const String _EXPANDED = 'panel-expanded';
  static const String _COLLAPSED = 'panel-collapsed';

  @observable String panelStyle = _EXPANDED;
  StreamSubscription<Event> _scrollHandler;

  int _minHeight;
  int _maxHeight;
  Element _panel;

  IntroHeaderElement.created() : super.created();

  @override
  void attached() {
    _panel = shadowRoot.querySelector('#panel');
    window.onResize.listen((_) {
      _fullReset();
    });

    _scrollHandler = window.onScroll.listen((_) {
      _updatePanel();
    });

    _fullReset();
  }

  void _fullReset() {
    var oldClassName = _panel.className;
    var oldHeight = _panel.style.height;

    _panel.style.height = '';
    _panel.className = _COLLAPSED;
    _minHeight = _panel.clientHeight;
    _panel.className = _EXPANDED;
    _maxHeight = _panel.clientHeight;

    _panel.className = oldClassName;
    _panel.style.height = oldHeight;

    _updatePanel();
  }

  void _updatePanel() {
    if (window.pageYOffset > _maxHeight - _minHeight) {
      panelStyle = _COLLAPSED;
      _panel.style.height = '';
    } else if (window.pageYOffset > 0) {
      _panel.style.height = '${_maxHeight - window.pageYOffset}px';
    } else {
      panelStyle = _EXPANDED;
      _panel.style.height = '';
    }
  }
}