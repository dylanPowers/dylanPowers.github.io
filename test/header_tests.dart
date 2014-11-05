part of about_me_tests;

class HeaderTests {
  static IntroHeaderElement _header;

  static void run() {
    describe('The intro header', () {
      it('has a working element factory constructor', _introHeaderFactoryWorks);

      beforeEach(_headerSetUp);
      afterEach(_headerTearDown);

      it('is present until the first card is reached',
         _isPresentUntilFirstCardReached);
      it('is present when slowly scrolling up past the first card',
         _isPresentWhenSlowlyScrolling);
      it('scrolls into view upon scrolling up when hidden', _scrollsIntoView);
    });
  }

  static void _headerSetUp() {
    _header = new IntroHeaderElement();
    _header.id = 'header-test-el';
    document.body.append(_header);

    var extraHeight = new Element.div();
    extraHeight.id = 'extra-height';
    extraHeight.style.height = '5000px';
    document.body.append(extraHeight);
  }

  static void _headerTearDown() {
    _header.remove();
    
    var extraHeight = document.getElementById('extra-height');
    extraHeight.remove();
  }

  static void _introHeaderFactoryWorks() {
    expect(() => new IntroHeaderElement()).not.toThrow();
  }

  static Future _isPresentUntilFirstCardReached() {
    window.scroll(0, 500);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    });
  }
  
  static Future _isPresentWhenSlowlyScrolling() {
    window.scroll(0, 502);
    return window.animationFrame.then((_) {
      window.scroll(0, 500);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    });
  }

  static Future _scrollsIntoView() {
    window.scroll(0, 600);
    return window.animationFrame.then((_) {
      window.scroll(0, 599);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
      var panel = _header.shadowRoot.getElementById('panel');
      expect(panel.offsetTop).toEqual(-41);
    });
  }
}