library enhanced_window_on_scroll;

import 'dart:async';
import 'dart:html' as html;

import 'package:angular/angular.dart';

@Injectable()
class EnhancedWindowOnScroll {
  Stream<EnhancedScrollEvent> get stream => _stream;
  
  Stream<EnhancedScrollEvent> _stream;
  final html.Window _win = html.window;
  
  EnhancedWindowOnScroll() {
    _stream = new Stream<EnhancedScrollEvent>.eventTransformed(_win.onScroll,
                                                               _mapSink);
  }
  
  EventSink _mapSink(EventSink<EnhancedScrollEvent> sink) {
    return new EnhancedScrollSink(sink, _win);
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


class EnhancedScrollSink extends EventSink<html.Event> {
  int _lastScrollX = 0;
  int _lastScrollY = 0;
  final EventSink<EnhancedScrollEvent> _outputSink;

  final html.Window _win;
  EnhancedScrollSink(this._outputSink, this._win);

  void add(html.Event data) {
    var scrollE = new EnhancedScrollEvent(_lastScrollX, _lastScrollY,
    _win.pageXOffset, _win.pageYOffset);
    _lastScrollX = scrollE.newXPosition;
    _lastScrollY = scrollE.newYPosition;

    _outputSink.add(scrollE);
  }

  void addError(e, [stackTrace]) => _outputSink.addError(e, stackTrace);
  void close() => _outputSink.close();
}