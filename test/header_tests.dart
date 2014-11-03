part of about_me_tests;

class HeaderTests {
  static IntroHeaderElement _header;
  static void run() {
    group('The intro header', () {

      test('intro header expects an enhanced window scroll stream', () {
        inject((Window win, EnhancedWindowOnScroll scroll) {
          expect(() => new IntroHeaderElement(scroll), returnsNormally);
        });
      });

      test('should run async code', async(() {
        var thenRan = false;
        new Future.value('s').then((_) { thenRan = true; });
        expect(thenRan, isFalse);
        microLeap();
        expect(thenRan, isTrue);
      }));
      
      test('should run injected async code', async(inject((Http http, MockHttpBackend backend) {
        var thenRan = false;
        backend.expectGET('http://www.google.com/').respond('');  
        http.get('http://www.google.com/').then((_) { thenRan = true; });
        backend.flush();
        expect(thenRan, isFalse);
        microLeap();
        expect(thenRan, isTrue);
      })));

      setUp(() => module((Module m) => m.bind(Window, toValue: window)));
      test('injected window has an onScroll stream', inject((Window win) {
        expect(win.onScroll, isNotNull);
      }));

      setUp(() => loadTemplate('packages/about_me/header/intro_header.html'));
      
      test('intro header accepts a shadow root', async(inject((TestBed tb, 
                                                               IntroHeaderElement header) {
        Element headerElement = tb.compile('<intro-header></intro-header>');
        microLeap();
        tb.rootScope.apply();

        expect(() {
          header.onShadowRoot(headerElement.shadowRoot);
        }, returnsNormally);
      })));
      
      setUp(headerSetUp);

      skip_test('banner is present until the first card is reached',
           bannerIsPresentUntilFirstCardReached);
      
      skip_test('banner is present when slowly scrolling up past the first card',
                bannerIsPresentWhenSlowlyScrolling);
    });
  }

  static Future headerSetUp() {
    return loadTemplate('packages/about_me/header/intro_header.html').then((_) {
      inject((TestBed tb, IntroHeaderElement header) {
        Element headerElement;
        async(() {
          headerElement = tb.compile('<intro-header></intro-header>');
          microLeap();
        }).call();
        tb.rootScope.apply();

        header.onShadowRoot(headerElement.shadowRoot);
        _header = header;
      });
    });
  }


  static dynamic bannerIsPresentUntilFirstCardReached() {
    return async(inject((Window win) {
      win.scroll(0, 700);
     
      microLeap();
      
      expect(_header.panelDisplayStyle, equals('panel-displayed'));
    }));
  }
  
  static dynamic bannerIsPresentWhenSlowlyScrolling() {
    return async(inject((Window win) {
      win.scroll(0, 502);
      microLeap();
      win.scroll(0, 500);
      microLeap();
      expect(_header.panelDisplayStyle, equals('panel-displayed'));
    }));
  }
}