part of about_me_tests;

class EnhancedWindowScrollTests {
  static void run() {
    describe('Enhanced window scroll', () {  
      describe('sink', () {
        it('can have HTML events added',
        _htmlEventsCanBeAddedToScrollSink);
      });
      
      it('is injectable', () {
        expect(() => inject((EnhancedWindowOnScroll scroll) {})).not.toThrow();
      });
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
}