part of about_me_tests;

class HeaderTests {
  static IntroHeaderElement _header;
  static void run() {
    describe('The intro header', () {

      it('expects a constructor that accepts an enhanced window scroll',
         constructorExpectsEnhancedWindowScroll);

      it('has an onShadowRoot that runs cleanly', onShadowRootRuns);

      beforeEach(headerSetUp);
      it('is present until the first card is reached',
           bannerIsPresentUntilFirstCardReached);
      
      it('is present when slowly scrolling up past the first card',
           bannerIsPresentWhenSlowlyScrolling);
    });
  }

  static Future headerSetUp() {
    return loadNCompileTemplate('packages/about_me/header/intro_header.html', 
                                '<intro-header></intro-header>')
    .then((Element headerElement) {
      inject((IntroHeaderElement header) {
        header.onShadowRoot(headerElement.shadowRoot);
        _header = header;
      });
    });
  }

  static void constructorExpectsEnhancedWindowScroll() {
    inject((Window win, EnhancedWindowOnScroll scroll) {
      expect(() => new IntroHeaderElement(scroll)).not.toThrow();
    });
  }
  
  static Future onShadowRootRuns() {
    return loadNCompileTemplate('packages/about_me/header/intro_header.html',
                                '<intro-header></intro-header>')
    .then((Element headerElement) {
      inject((IntroHeaderElement header) {
        expect(() => header.onShadowRoot(headerElement.shadowRoot)).not.toThrow();
      });
    });
  }

  static dynamic bannerIsPresentUntilFirstCardReached() {
    return async(inject((Window win) {
      win.scroll(0, 700);
     
      microLeap();
      
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    }));
  }
  
  static dynamic bannerIsPresentWhenSlowlyScrolling() {
    return async(inject((Window win) {
      win.scroll(0, 502);
      microLeap();
      win.scroll(0, 500);
      microLeap();
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    }));
  }
}