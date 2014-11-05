part of about_me_tests;

class HeaderTests {
  static void run() {
    describe('The intro header', () {
      it('has a working element factory constructor', introHeaderFactoryWorks);

      beforeEach(headerSetUp);
      afterEach(headerTearDown);

      it('is present until the first card is reached',
         isPresentUntilFirstCardReached);
      it('is present when slowly scrolling up past the first card',
         isPresentWhenSlowlyScrolling);
    });
  }

  static void headerSetUp() {
    var el = new IntroHeaderElement();
    el.id = 'header-test-el';
    document.body.append(el);

    var extraHeight = new Element.div();
    extraHeight.id = 'extra-height';
    extraHeight.style.height = '5000px';
    document.body.append(extraHeight);
  }

  static void headerTearDown() {
    var el = document.getElementById('header-test-el');
    el.remove();
    
    var extraHeight = document.getElementById('extra-height');
    extraHeight.remove();
  }

  static void introHeaderFactoryWorks() {
    expect(() => new IntroHeaderElement()).not.toThrow();
  }

  static Future isPresentUntilFirstCardReached() {
    window.scroll(0, 500);
    return window.animationFrame.then((_) {
      var shadowRoot = document.getElementById('header-test-el').shadowRoot;
      var panel = shadowRoot.getElementById('panel');
      expect(panel.classes).toContain('panel-displayed');
    });
  }
  
  static Future isPresentWhenSlowlyScrolling() {
    window.scroll(0, 502);
    return window.animationFrame.then((_) {
      window.scroll(0, 500);
      return window.animationFrame;
    }).then((_) {
      IntroHeaderElement header = document.getElementById('header-test-el');
      expect(header.panelDisplayStyle).toEqual('panel-displayed');
    });
  }
}