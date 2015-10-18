library overflowed_links_menu_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:paper_elements/paper_dropdown.dart';
import 'package:unittest/unittest.dart' as ut;

import 'package:about_me/header/header.dart';

OverflowedLinksMenuElement _overLinksMenu;

void run() {
  describe('The overflowed links menu', () {
    beforeEach(() {
      _overLinksMenu = new OverflowedLinksMenuElement();
      document.body.append(_overLinksMenu);
    });
    afterEach(() => _overLinksMenu.remove());

    it('has a working element factory constructor', () =>
        expect(() => new OverflowedLinksMenuElement()).not.toThrow());

    it('has an attribute that holds a list of OverflowedLinks', () {
      expect(_overLinksMenu.overflowedLinks,
             new ut.isInstanceOf<List<OverflowedHeaderLink>>());
    });

    it('has an attribute that describes whether or not the menu is opened', () {
      expect(() => _overLinksMenu.menuPossiblyOpened).not.toThrow();
      expect(_overLinksMenu.menuPossiblyOpened, new ut.isInstanceOf<bool>());
    });

    it('has a property for accessing the menu button dimensions', () {
      expect(() => _overLinksMenu.buttonDimensions).not.toThrow();
      expect(_overLinksMenu.buttonDimensions, new ut.isInstanceOf<Rectangle>());
    });

    _openClosedStateTests();
  });

  describe('The OverflowedHeaderLink', () {
    it('has the href set to the url when the user is null', () {
      HtmlElement el = new DivElement();
      var url = "a.url";
      el.setAttribute("url", url);
      var link = new OverflowedHeaderLink(el);
      expect(link.href, ut.equals(url));
    });
  });
}

void _openClosedStateTests() {
  describe('when open vs closed state', () {
    PaperDropdown dropdown;
    beforeEach(() {
      dropdown = _overLinksMenu.shadowRoot.getElementById('links-dropdown');
      _overLinksMenu.menuPossiblyOpened = true;
      return window.animationFrame;
    });

    // TODO Someday figure out how to do this. I think the easiest way would
    // be to get the underlying paper dropdown to have an open/close event.
//    xit('is set to open the menu is open', () {
//      expect(dropdown.opened).toBeTrue();
//    });

    it('is set to closed the menu is closed', () {
      _overLinksMenu.menuPossiblyOpened = false;
      return window.animationFrame
                   .then((_) => expect(dropdown.opened).toBeFalse());
    });
  });
}
