library intro_header_tests;

import 'dart:async';
import 'dart:html';
import 'package:guinness/guinness.dart';

import 'package:about_me/css_style_props.dart';
import 'package:about_me/header/intro_header.dart';

const _WAIT_TIME = 500;

IntroHeaderElement _header;
Element _panel;

void runHeaderTests() {
  describe('The intro header', () {
    beforeEach(_stdSetUp);
    afterEach(_stdTearDown);

    it('has a working element factory constructor', () =>
       expect(() => new IntroHeaderElement()).not.toThrow());

    it('hides with the page when scrolling down at the expanded to condensed transition', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(1px)');
      });
    });

    it('does not immediately display when scrolling up near the expanded to condensed transition', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, -1);
        return window.animationFrame;
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(2px)');
      });
    });

    it('is not moved after scrolling down until partially hidden, and then ' +
        'scrolling back up to the top', () {
      window.scrollBy(0, _panel.clientHeight);
      return window.animationFrame.then((_) {
        // This bug is caused by some intermediary scroll events
        window.scrollBy(0, -20);
        return window.animationFrame;
      }).then((_) {
        window.scroll(0, 0);
        return window.animationFrame;
      }).then((_) {
        expect(_panel.getBoundingClientRect().top).toEqual(0);
      });
    });

    _condensedViewTests();
  });
}

void _stdSetUp() {
  _header = new IntroHeaderElement();
  _header.id = 'header-test';
  document.body.append(_header);

  _panel = _header.shadowRoot.getElementById('panel');

  var extraHeight = new Element.div();
  extraHeight.id = 'extra-height';
  extraHeight.style.height = '5000px';
  document.body.append(extraHeight);
}

void _stdTearDown() {
  _header.remove();

  var extraHeight = document.getElementById('extra-height');
  extraHeight.remove();
}

final _SCROLL_START = 600;
void _condensedViewTests() {
  describe('when scrolled out of expanded view', () {
    beforeEach(() {
      window.scroll(0, _SCROLL_START);
      return window.animationFrame;
    });

    it('is currently out of view', () {
      expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
      expect(_panel.style.transform).toEqual('translateY(0px)');
    });

    it('is hidden when scrolled down by 1px and up by 1 px', () {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, 1);
        return window.animationFrame;
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    it('has a 150ms transition duration after sitting for ${_WAIT_TIME}ms', () {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        return new Future.delayed(new Duration(milliseconds: _WAIT_TIME));
      }).then((_) {
        return window.animationFrame;
      }).then((_) {
        expect(_panel.style.transitionDuration).toEqual('150ms');
      });
    });

    it('has a top value equivalent to the ytranslation after sitting for ' +
       '${_WAIT_TIME}ms', () {
      window.scrollBy(0, -1);
      num oldTranslationVal;
      return window.animationFrame.then((_) {
        oldTranslationVal = new CssTransformProp(_panel.style).translateY;
        return new Future.delayed(new Duration(milliseconds: _WAIT_TIME));
      }).then((_) {
        expect(_panel.getComputedStyle().top).toEqual('${-_panel.clientHeight + oldTranslationVal}px');
      });
    });

    it('has a 0 ms transition immediately after scrolling after a previous ' +
       '"scroll then wait ${_WAIT_TIME}ms"', () {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        return new Future.delayed(new Duration(milliseconds: _WAIT_TIME));
      }).then((_) {
        window.scrollBy(0, -1);
        return window.animationFrame;
      }).then((_) {
        expect(_panel.style.transitionDuration).toEqual('');
      });
    });

    it('while being partially shown for 500ms and scrolled above the ' +
       'expanded header bottom, the condensed view is displayed', () {
      window.scroll(0, _panel.clientHeight);
      return window.animationFrame.then((_) {
        window.scrollBy(0, -1);
        return window.animationFrame;
      }).then((_) {
        return new Future.delayed(new Duration(milliseconds: 500));
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_DISPLAYED);
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    _scrollingUpTests();
    _scrollingDownTests();
  });
}

void _scrollingUpTests() {
  describe('while scrolling up', () {
    it('scrolls by 1px upon scrolling by 1px', () {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(1px)');
      });
    });

    it('scrolls by 41px upon scrolling by 41px', () {
      window.scrollBy(0, -41);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(41px)');
      });
    });

    it('scrolls by 2px upon scrolling 1px then 1px again',() {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, -1);
        return window.animationFrame;
      }).then((_) {
        expect(_panel.style.transform).toEqual('translateY(2px)');
      });
    });

    it('stops scrolling when top is reached', () {
      window.scrollBy(0, -20);
      return window.animationFrame.then((_) {
        window.scrollBy(0, -_panel.clientHeight + 20);
        return window.animationFrame;
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_DISPLAYED);
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    it('stops scrolling after displayed', () {
      window.scrollBy(0, -_panel.clientHeight);
      return window.animationFrame.then((_) {
        window.scrollBy(0, -1);
        return window.animationFrame;
      }).then((_) {
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    it('has css transitioning turned off',() {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        expect(_panel.getComputedStyle().transitionDuration).toEqual('0s');
      });
    });


    it('while being partially displayed is hidden after sitting for 500ms', () {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        return new Future.delayed(new Duration(milliseconds: 500));
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
      });
    });
  });
}

void _scrollingDownTests() {
  describe('while scrolling down', () {
    beforeEach(() {
      window.scrollBy(0, -_panel.clientHeight);
      return window.animationFrame;
    });

    it('is currently in view', () {
      expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_DISPLAYED);
      expect(_panel.style.transform).toEqual('translateY(0px)');
    });

    it('scrolls by 1px upon scrolling by 1px', () {
      window.scrollBy(0, 1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(${_panel.clientHeight - 1}px)');
      });
    });

    it('scrolls by its height - 1px upon scrolling by that amount', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(1px)');
      });
    });

    it('scrolls by 2px upon scrolling 1px then 1px again', () {
      window.scrollBy(0, 1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, 1);
        return window.animationFrame;
      }).then((_) {
        expect(_panel.style.transform).toEqual('translateY(${_panel.clientHeight - 2}px)');
      });
    });

    it('stops scrolling past hidden view state', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, 2);
        return window.animationFrame;
      }).then((_) {
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    it('while being partially displayed is hidden after sitting for 500ms', () {
      window.scrollBy(0, 1);
      return window.animationFrame.then((_) {
        return new Future.delayed(new Duration(milliseconds: 500));
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(IntroHeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });
  });
}