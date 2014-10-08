import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  Element _panelEl;
  StreamSubscription<Event> _scrollHandler;
  
  IntroHeaderElement.created() : super.created() {
    _panelEl = shadowRoot.getElementById('panel');
  }

  @override
  void attached() {
    String standardHeight = _panelEl.style.height;
    _scrollHandler = window.onScroll.listen((_) {
      if (window.pageYOffset > 25) {
        _panelEl.style.height = "36px";
      } else {
        _panelEl.style.height = standardHeight;
      }
    });
  }
}