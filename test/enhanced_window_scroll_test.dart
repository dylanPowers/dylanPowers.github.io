part of about_me_tests;

class EnhancedWindowScrollTests {
  static void run() {
    group('Enhanced window scroll', () {
      test('Enhanced scroll sink constructor accepts a window object',
           _scrollSinkConstructAcceptsWinObj);
      
      test('HTML events can be added to the scroll sink', 
           _htmlEventsCanBeAddedToScrollSink);
    });
  }
  
  static void _scrollSinkConstructAcceptsWinObj() {
    inject((Window win) {
      var sink = new StreamController();
      expect(() => new EnhancedScrollSink(sink, win), returnsNormally);
      expect(new EnhancedScrollSink(sink, win), isNotNull);
    });
  }
  
  static void _htmlEventsCanBeAddedToScrollSink() {
    inject((Window win) {
      var sink = new EnhancedScrollSink(new StreamController(), win);
      expect(() => sink.add(new Event('Dummy')), returnsNormally);
    });
  }
}