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
    
    return loadNCompileTemplate('packages/about_me/header/intro_header.html', 
                                '<intro-header></intro-header>')
    .then((Element headerElement) {
      headerElement.id = 'header-test';
      document.body.append(headerElement);
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

  static dynamic isPresentUntilFirstCardReached() {
    return async(inject((Window win) {
      win.scroll(0, 700);
     
      microLeap();
      
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    }));
  }
  
  static dynamic isPresentWhenSlowlyScrolling() {
    return async(inject((Window win) {
      win.scroll(0, 502);
      microLeap();
      win.scroll(0, 500);
      microLeap();
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    }));
  }
  
  static dynamic isHiddenWhenScrolledDown() {
    return async(inject((Window win) {
      win.scroll(0, 700);
      microLeap();
      
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
    }));
  }
}