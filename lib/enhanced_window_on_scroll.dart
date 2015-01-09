library enhanced_window_on_scroll;

import 'dart:async';
import 'dart:html';

/**
 * OnScroll events for the window object are really lacking. This library
 * enhances those
 * events so that they have information such as the old position, the new
 * position, and the size of the movement.
 */

/**
 * Initialize this class to the window object and listen on its stream
 * property to handle events.
 */
class EnhancedWindowOnScroll {
  Stream<EnhancedScrollEvent> get stream => _stream;

  Stream<EnhancedScrollEvent> _stream;
  final Window _win;

  EnhancedWindowOnScroll(this._win) {
    _stream = new Stream<EnhancedScrollEvent>.eventTransformed(_win.onScroll, _mapSink);
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

  EnhancedScrollEvent.zeroMovement(Window win) :
    this.oldXPosition = win.pageXOffset,
    this.newXPosition = win.pageXOffset,
    this.oldYPosition = win.pageYOffset,
    this.newYPosition = win.pageYOffset;
}

class EnhancedScrollSink extends EventSink<Event> {
  int _lastScrollX = 0;
  int _lastScrollY = 0;
  final EventSink<EnhancedScrollEvent> _outputSink;

  final Window _win;
  EnhancedScrollSink(this._outputSink, this._win);

  void add(Event data) {
    var scrollE = new EnhancedScrollEvent(_lastScrollX, _lastScrollY,
                                          _win.pageXOffset, _win.pageYOffset);
    _lastScrollX = scrollE.newXPosition;
    _lastScrollY = scrollE.newYPosition;

    _outputSink.add(scrollE);
  }

  void addError(e, [stackTrace]) => _outputSink.addError(e, stackTrace);
  void close() => _outputSink.close();
}