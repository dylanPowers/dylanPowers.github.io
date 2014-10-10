import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  @observable String panelStyle = 'panel-expanded';
  StreamSubscription<Event> _scrollHandler;
  
  IntroHeaderElement.created() : super.created();

  @override
  void attached() {
    _scrollHandler = window.onScroll.listen((_) {
      if (window.pageYOffset > 36) {
        panelStyle = 'panel-collapsed';
      } else {
        panelStyle = 'panel-expanded';
      }
    });
  }
}