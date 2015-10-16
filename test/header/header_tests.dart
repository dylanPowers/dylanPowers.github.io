library intro_header_tests;

import 'dart:async';
import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart' as ut;

import 'package:about_me/css_style_props.dart';
import 'package:about_me/header/header.dart';

import 'overflowed_links_menu_tests.dart' as overflowedLinksMenuTests;

const _SCROLL_START = 600;
const _WAIT_TIME = 500;

HeaderElement _header;
Element _panel;

void run() {
  overflowedLinksMenuTests.run();

  describe('The intro header', () {
    beforeEach(_stdSetUp);
    afterEach(_stdTearDown);

    it('has a working element factory constructor', () =>
       expect(() => new HeaderElement()).not.toThrow());

    it('hides with the page when scrolling down at the expanded to condensed transition', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(1px)');
      });
    });

    it('does not immediately display when scrolling up near the expanded to condensed transition', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, -1);
        return window.animationFrame;
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
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

    it('has a property for modifying the profile picture style', () {
      expect(() => _header.profilePicStyle, ut.returnsNormally);
    });

    it('when expanded sets the profile picture html element to the expanded style', () {
      var picEl = _header.shadowRoot.getElementById('profile-pic');
      expect(picEl.classes).toContain(HeaderElement.PIC_EXPANDED);
    });

    it('has a property for modifying the name style', () {
      expect(() => _header.nameStyle, ut.returnsNormally);
    });

    it('when expanded sets the name html element to the expanded style', () {
      var nameEl = _header.shadowRoot.getElementById('name');
      expect(nameEl.classes).toContain(HeaderElement.NAME_EXPANDED);
    });

    it('has a property for accessing the state of whether the additional ' +
       'links button should be shown', () {
      expect(() => _header.showLinksMenu, ut.returnsNormally);
      expect(_header.showLinksMenu).toBeAnInstanceOf(bool);
    });

    describe('property for accessing the overflowed header links', () {
      it('exists', () {
        expect(() => _header.overflowedLinks, ut.returnsNormally);
      });

      it('is an observable list of OverflowedHeaderLinks', () {
        expect(_header.overflowedLinks,
               new ut.isInstanceOf<ObservableList<OverflowedHeaderLink>>());
      });
    });

    it('has a property for modifying whether the overflowed links menu should be open', () {
      expect(() => _header.isOverflowedLinksMenuOpen, ut.returnsNormally);
      expect(_header.isOverflowedLinksMenuOpen).toBeAnInstanceOf(bool);
    });

    _condensedThenExpandedTests();
    _condensedViewTests();
  });

  describe('An overflowed header link', () {
    OverflowedHeaderLink link;
    beforeEach(() => link = new OverflowedHeaderLink(new Element.tag('header-link')));

    it('has a name property', () {
      expect(() => link.name, ut.returnsNormally);
    });

    it('has an href property', () {
      expect(() => link.href, ut.returnsNormally);
    });

    it('correctly sets the href property to the value from the header-link', () {
      var headerLink = new Element.tag('header-link');
      var url = 'a-website-url/';
      var user = 'randomUser';
      headerLink.setAttribute('url', url);
      headerLink.setAttribute('user', user);
      link = new OverflowedHeaderLink(headerLink);
      expect(link.href).toEqual(url + user);
    });

    it('correctly sets the name attribute from the alt attribute on the ' +
       'img content', () {
      var headerLink = new Element.tag('header-link');
      var alt = 'get a life';
      var imgEl = new Element.img()
          ..setAttribute('alt', alt);
      headerLink.append(imgEl);
      link = new OverflowedHeaderLink(headerLink);
      expect(link.name).toEqual(alt);
    });
  });
}

void _stdSetUp() {
  _header = new HeaderElement();
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

void _condensedThenExpandedTests() {
  describe('when scrolled down to condensed and back up to expanded', () {
    beforeEach(() {
      window.scrollBy(0, _panel.clientHeight);
      return window.animationFrame.then((_) {
        window.scroll(0, 0);
        return window.animationFrame;
      });
    });

    it('sets the profile picture style to expanded', (){
      window.scrollBy(0, _panel.clientHeight);
      return window.animationFrame.then((_) {
        window.scroll(0, 0);
        return window.animationFrame;
      }).then((_) {
        expect(_header.profilePicStyle).toEqual(HeaderElement.PIC_EXPANDED);
      });
    });

    it('sets the name style to expanded', () {
      window.scrollBy(0, _panel.clientHeight);
      return window.animationFrame.then((_) {
        window.scroll(0, 0);
        return window.animationFrame;
      }).then((_) {
        expect(_header.nameStyle).toEqual(HeaderElement.NAME_EXPANDED);
      });
    });
  });
}

void _condensedViewTests() {
  describe('when scrolled down to condensed view', () {
    beforeEach(() {
      window.scroll(0, _SCROLL_START);
      return window.animationFrame;
    });

    it('is currently out of view', () {
      expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
      expect(_panel.style.transform).toEqual('translateY(0px)');
    });

    it('is hidden when scrolled down by 1px and up by 1 px', () {
      window.scrollBy(0, -1);
      return window.animationFrame.then((_) {
        window.scrollBy(0, 1);
        return window.animationFrame;
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
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
        expect(_panel.getComputedStyle().top)
            .toEqual('${-_panel.clientHeight + oldTranslationVal}px');
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
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_DISPLAYED);
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    it('while having less than 25% hidden is displayed after sitting for 500ms', () {
      window.scrollBy(0, -3 * _panel.clientHeight ~/ 4 - 1);
      return window.animationFrame.then((_) {
        return new Future.delayed(new Duration(milliseconds: _WAIT_TIME));
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_DISPLAYED);
        expect(_panel.style.transform).toEqual('translateY(0px)');
      });
    });

    it('sets the profile pic style to condensed', () {
      expect(_header.profilePicStyle).toEqual(HeaderElement.PIC_CONDENSED);
    });

    it('sets the name style to condensed', () {
      expect(_header.nameStyle).toEqual(HeaderElement.NAME_CONDENSED);
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
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(1px)');
      });
    });

    it('scrolls by 41px upon scrolling by 41px', () {
      window.scrollBy(0, -41);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
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
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_DISPLAYED);
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
        return new Future.delayed(new Duration(milliseconds: _WAIT_TIME));
      }).then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
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
      expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_DISPLAYED);
      expect(_panel.style.transform).toEqual('translateY(0px)');
    });

    it('scrolls by 1px upon scrolling by 1px', () {
      window.scrollBy(0, 1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
        expect(_panel.style.transform).toEqual('translateY(${_panel.clientHeight - 1}px)');
      });
    });

    it('scrolls by its height - 1px upon scrolling by that amount', () {
      window.scrollBy(0, _panel.clientHeight - 1);
      return window.animationFrame.then((_) {
        expect(_header.panelDisplayStyle).toEqual(HeaderElement.PANEL_HIDDEN);
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

    it('closes the overflowed links menu', () {
      _header.isOverflowedLinksMenuOpen = true;
      window.scrollBy(0, 1);
      return window.animationFrame.then((_) {
        expect(_header.isOverflowedLinksMenuOpen).toBeFalse();
      });
    });
  });
}
