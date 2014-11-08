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
    it('is currently out of view', _currentlyOutofView);
    describe('while scrolling up', () {
      it('scrolls by 1px upon scrolling by 1px', _scrolls1pxIntoView);
      it('scrolls by 41px upon scrolling by 41px', _scrolls41pxIntoView);
      it('scrolls by 2px upon scrolling 1px then 1px again',
          _scrolls2pxWithDouble1pxScrolls);
      it('stops scrolling when top is reached', _stopsScrolling);
      it('stops scrolling after displayed', _stopScrollingWhenDisplayed);
      it('has css transitioning turned off',
         _hasNoCssTransitionScrollingUp);
    });
    
    describe('while scrolling down', () {
      beforeEach(() {
        var panel = _header.shadowRoot.getElementById('panel');
        window.scrollBy(0, -panel.clientHeight);
        return window.animationFrame;
      });

      it('is currently in view', _currentlyInView);
      it('scrolls by 1px upon scrolling by 1px', _scrolls1pxOutofView);
      it('scrolls by its height - 1px upon scrolling by that amount', _scrollsHieghtMinus1pxOutofView);
      it('scrolls by 2px upon scrolling 1px then 1px again', _double1pxScrollsDown);
      it('stops scrolling past hidden view state', _scrollPastHidden);
    });
    
    it('is hidden when scrolled down by 1px and up by 1 px', 
       _isHiddenWhenScrolledUpThenDown);
  }

  Future _beforeEach() {
    _header = document.getElementById('header-test');
    window.scroll(0, _SCROLL_START);
    return window.animationFrame;
  }
  
  void _currentlyOutofView() {
    expect(_header.panelDisplayStyle).toEqual('panel-hidden');
    expect(_header.panelYTranslation).toEqual(0);
  }

  void _currentlyInView() {
    expect(_header.panelDisplayStyle).toEqual('panel-displayed');
    expect(_header.panelYTranslation).toEqual(0);
  }
  
  Future _scrolls1pxIntoView() {
    window.scrollBy(0, -1);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(1);
    });
  }
  
  Future _scrolls1pxOutofView() {
    var panel = _header.shadowRoot.getElementById('panel');
    window.scrollBy(0, 1);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(panel.clientHeight - 1);
    });
  }

  Future _scrolls41pxIntoView() {
    window.scroll(0, _SCROLL_START - 41);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(41);
    });
  }

  Future _scrollsHieghtMinus1pxOutofView() {
    var panel = _header.shadowRoot.getElementById('panel');
    window.scrollBy(0, panel.clientHeight - 1);
    return window.animationFrame.then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(1);
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
  
  Future _double1pxScrollsDown() {
    var panel = _header.shadowRoot.getElementById('panel');
    window.scrollBy(0, 1);
    return window.animationFrame.then((_) {
      window.scrollBy(0, 1);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelYTranslation).toEqual(panel.clientHeight - 2);
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

  Future _scrollPastHidden() {
    var panel = _header.shadowRoot.getElementById('panel');
    window.scrollBy(0, panel.clientHeight - 1);
    return window.animationFrame.then((_) {
      window.scrollBy(0, 2);
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
  
  Future _isHiddenWhenScrolledUpThenDown() {
    window.scrollBy(0, -1);
    return window.animationFrame.then((_) {
      window.scrollBy(0, 1);
      return window.animationFrame;
    }).then((_) {
      expect(_header.panelDisplayStyle).toEqual('panel-hidden');
      expect(_header.panelYTranslation).toEqual(0);
    });
  }
}