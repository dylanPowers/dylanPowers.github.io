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

      describe('when scrolled out of expanded view', _whenScrolledOutOfExpandedView);
    });
  }

  static void _headerSetUp() {
    _header = new IntroHeaderElement();
    _header.id = 'header-test';
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
}

void _whenScrolledOutOfExpandedView() => new _WhenScrolledOutOfExpandedView();

class _WhenScrolledOutOfExpandedView {
  IntroHeaderElement _header;
  _WhenScrolledOutOfExpandedView() {
    beforeEach(_beforeEach);
    it('scrolls by 1px upon scrolling up by 1px', _scrolls1pxIntoView);
    it('scrolls by 41px upon scrolling up by 41px', _scrolls41pxIntoView);
  }

  Future _beforeEach() {
    _header = document.getElementById('header-test');
  }

  Future _scrolls1pxIntoView() {
    window.scroll(0, 600);
    return window.animationFrame.then((_) {
      window.scroll(0, 599);
      return window.animationFrame;
    }).then((_) {
      return new Future(() {});
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(-1);
    });
  }

  Future _scrolls41pxIntoView() {
    window.scroll(0, 600);
    return window.animationFrame.then((_) {
      window.scroll(0, 600 - 41);
      return window.animationFrame;
    }).then((_) {
      return new Future(() {});
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(-41);
    });
  }
}