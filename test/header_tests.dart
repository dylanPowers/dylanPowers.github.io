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
  static const _SCROLL_START = 600;

  IntroHeaderElement _header;

  _WhenScrolledOutOfExpandedView() {
    beforeEach(_beforeEach);
    it('scrolls by 1px upon scrolling up by 1px', _scrolls1pxIntoView);
    it('scrolls by 41px upon scrolling up by 41px', _scrolls41pxIntoView);
    it('scrolls by 2px upon scrolling 1px then 1px again',
       _scrolls2pxWithDouble1pxScrolls);
    it('stops scrolling when top is reached', _stopsScrolling);
    it('stops scrolling after displayed', _stopScrollingWhenDisplayed);
    it('has css transitioning turned off while scrolling up', 
       _hasNoCssTransitionScrollingUp);
    
    it('scrolls by 1px upon scrolling down by 1px', _scrolls1pxOutofView);
  }

  Future _beforeEach() {
    _header = document.getElementById('header-test');
    window.scroll(0, _SCROLL_START);
    return window.animationFrame;
  }

  Future _scrolls1pxIntoView() {
    window.scroll(0, _SCROLL_START - 1);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(1);
    });
  }
  
  Future _scrolls1pxOutofView() {
    window.scroll(0, _SCROLL_START - 1);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(1);
    });
  }

  Future _scrolls41pxIntoView() {
    window.scroll(0, _SCROLL_START - 41);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(41);
    });
  }

  Future _scrolls2pxWithDouble1pxScrolls() {
    window.scrollBy(0, -1);
    return window.animationFrame.then((_) {
      window.scrollBy(0, -1);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelYTranslation).toEqual(2);
    });
  }
  
  Future _stopsScrolling() {
    var panel = _header.shadowRoot.getElementById('panel');
    var styleRangeEvaluator = new ElementStyleRangeEvaluator(panel);
    Interval heightRange = styleRangeEvaluator.evalTop('panel-hidden', 'panel-displayed');
    window.scrollBy(0, -20);
    return window.animationFrame.then((_) {
      window.scrollBy(0, -heightRange.range + 20);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-displayed');
      expect(_header.panelYTranslation).toEqual(0);
    });
  }
  
  Future _stopScrollingWhenDisplayed() {
    var panel = _header.shadowRoot.getElementById('panel');
    var styleRangeEvaluator = new ElementStyleRangeEvaluator(panel);
    Interval heightRange = styleRangeEvaluator.evalTop('panel-hidden', 'panel-displayed');
    window.scrollBy(0, -heightRange.range);
    return window.animationFrame.then((_) {
      window.scrollBy(0, -1);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelYTranslation).toEqual(0);
    });
  }
  
  Future _hasNoCssTransitionScrollingUp() {
    var panel = _header.shadowRoot.getElementById('panel');
    window.scrollBy(0, -1);
    return window.animationFrame.then((_) {
      expect(panel.getComputedStyle().transitionDuration).toEqual('0s');
    });
  }
}