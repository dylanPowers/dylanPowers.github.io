part of about_me_tests;

class HeaderTests {
  static void run() {
    group('The intro header', () {
      setUp(headerSetUp);
      tearDown(headerTearDown);

      test('banner is present until the first card is reached',
           bannerIsPresentUntilFirstCardReached);
      
      test('banner is present when slowly scrolling up past the first card',
           bannerIsPresentWhenSlowlyScrolling);
    });
  }

  static void headerSetUp() {
    module((Module m) => m.bind(Window, toValue: new MockWindow()));
    
//    var extraHeight = new Element.div();
//    extraHeight.id = 'extra-height';
//    extraHeight.style.height = '5000px';
//    document.body.append(extraHeight);
  }

  static void headerTearDown() {    
//    var extraHeight = document.getElementById('extra-height');
//    extraHeight.remove();
  }

  static Future bannerIsPresentUntilFirstCardReached() {
    return async(inject((IntroHeaderElement header, ShadowRoot shadowRoot, Window win) {
      header.onShadowRoot(shadowRoot);
      win.scroll(0, 500);
      
      microLeap();
      
      expect(header.panelDisplayStyle, equals('panel-displayed'));
    }));
  }
  
  static void bannerIsPresentWhenSlowlyScrolling() {
    async(inject((IntroHeaderElement header, Window win) {
      win.scroll(0, 502);
      microLeap();
      win.scroll(0, 500);
      microLeap();
      expect(header.panelDisplayStyle, equals('panel-displayed'));
    }));
  }
}