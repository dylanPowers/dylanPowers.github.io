part of about_me_tests;

class HeaderTests {
  static IntroHeaderElement _header;
  static void run() {
    describe('The intro header', () {

      it('expects a constructor that accepts an enhanced window scroll',
         constructorExpectsEnhancedWindowScroll);
      it('has an onShadowRoot that runs cleanly', onShadowRootRuns);

      beforeEach(headerSetUp);
      afterEach(headerTearDown);
      it('is present until the first card is reached',
         isPresentUntilFirstCardReached);  
      it('is present when slowly scrolling up past the first card',
         isPresentWhenSlowlyScrolling);
      it('is hidden when scrolled down to 700px', isHiddenWhenScrolledDown);
    });
  }

  static Future headerSetUp() {
    var extraHeight = new Element.div();
    extraHeight.id = 'extra-height';
    extraHeight.style.height = '5000px';
    document.body.append(extraHeight);

    Element headerElement;
    return loadNCompileTemplate('packages/about_me/header/intro_header.html',
                                '<intro-header></intro-header>')
    .then((Element template) {
      headerElement = template;
      headerElement.id = 'header-test';
      document.body.append(headerElement);
      return window.animationFrame;
    }).then((_) {
      inject((IntroHeaderElement header) {
        header.onShadowRoot(headerElement.shadowRoot);
        _header = header; 
      });
    });
  }

  static void headerTearDown() {
    var headerTest = document.getElementById('header-test');
    headerTest.remove();
    
    var extraHeight = document.getElementById('extra-height');
    extraHeight.remove();
  }

  static void constructorExpectsEnhancedWindowScroll() {
    EnhancedWindowOnScroll scroll;
    inject((EnhancedWindowOnScroll injScroll) {
      scroll = injScroll;
    });
    expect(() => new IntroHeaderElement(scroll)).not.toThrow();
  }
  
  static Future onShadowRootRuns() {

    return loadNCompileTemplate('packages/about_me/header/intro_header.html',
                                '<intro-header></intro-header>')
    .then((Element headerElement) {
      IntroHeaderElement header;
      inject((IntroHeaderElement injHeader) {
        header = injHeader;
      });
      expect(() => header.onShadowRoot(headerElement.shadowRoot)).not.toThrow();
    });
  }

  static Future isPresentUntilFirstCardReached() {
    window.scroll(0, 500);

    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    });
  }
  
  static Future isPresentWhenSlowlyScrolling() {
    window.scroll(0, 502);

    return window.animationFrame.then((_) {
      window.scroll(0, 500);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    });
  }
  
  static Future isHiddenWhenScrolledDown() {
    window.scroll(0, 700);

    return window.animationFrame.then((_) {
      return expect(_header.panelDisplayStyle).toEqual('panel-hidden');
    });
  }
}