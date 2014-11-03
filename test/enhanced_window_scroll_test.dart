part of about_me_tests;

class EnhancedWindowScrollTests {
  static void run() {
    group('Enhanced window scroll', () {            
      test('HTML events can be added to the scroll sink', 
           _htmlEventsCanBeAddedToScrollSink);
      
      test('EnhancedWindowOnScroll is injectable', () {
        expect(() => inject((EnhancedWindowOnScroll scroll) {}), returnsNormally);
      });
    });
  }
  
  static void _scrollSinkConstructAcceptsWinObj() {
    var sink = new StreamController();
    expect(() => new EnhancedScrollSink(sink, window), returnsNormally);
    expect(new EnhancedScrollSink(sink, window), isNotNull);
  }
  
  static void _htmlEventsCanBeAddedToScrollSink() {
    var sink = new EnhancedScrollSink(new StreamController(), window);
    expect(() => sink.add(new Event('Dummy')), returnsNormally);
  }
}