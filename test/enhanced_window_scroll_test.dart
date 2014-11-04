part of about_me_tests;

class EnhancedWindowScrollTests {
  static void run() {
    describe('Enhanced window scroll', () {  
      describe('sink', () {
        it('can have HTML events added',
           _htmlEventsCanBeAddedToScrollSink);
        it('has a constructor that accepts a window object', 
           _scrollSinkConstructAcceptsWinObj);
      });
      
      it('is injectable', () {
        expect(() => inject((EnhancedWindowOnScroll scroll) {})).not.toThrow();
      });

      it('reacts to window scroll events', _reactsToScrollEvents);
    });
  }
  
  static void _scrollSinkConstructAcceptsWinObj() {
    var sink = new StreamController();
    expect(() => new EnhancedScrollSink(sink, window)).not.toThrow();
    expect(new EnhancedScrollSink(sink, window)).toBeNotNull();
  }
  
  static void _htmlEventsCanBeAddedToScrollSink() {
    var sink = new EnhancedScrollSink(new StreamController(), window);
    expect(() => sink.add(new Event('Dummy'))).not.toThrow();
  }
  
  static Future _reactsToScrollEvents() {
    SpyFunction callback = guinness.createSpy('On scroll callback');
    StreamSubscription subscript;

    var extraHeight = new Element.div();
    extraHeight.id = 'extra-height';
    extraHeight.style.height = '5000px';
    document.body.append(extraHeight);

    inject((EnhancedWindowOnScroll eScroll) {
      subscript = eScroll.stream.listen(callback);
    });
    window.scroll(0, 100);

    return window.animationFrame.then((_) {
      subscript.cancel();
      return expect(callback).toHaveBeenCalledOnce();
    });
  }
}