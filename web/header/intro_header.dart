import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';


@CustomTag('intro-header')
class IntroHeaderElement extends PolymerElement {
  Element panelEl;
  StreamSubscription<Event> scrollHandler;
  
  IntroHeaderElement.created() : super.created() {
    panelEl = document.getElementById('panel');
    
  }
}