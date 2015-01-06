library overflowed_links_menu_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' as ut;

import 'package:about_me/header/header.dart';

void run() {
  ddescribe('The overflowed links menu', () {
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

    it('has an attribute that describes whether or not the menu should be open', () {
      expect(() => _overLinksMenu.isMenuOpen).not.toThrow();
      expect(_overLinksMenu.isMenuOpen, new ut.isInstanceOf<bool>());
    });

    it('has a property for accessing the menu button dimensions', () {
      expect(() => _overLinksMenu.buttonDimensions).not.toThrow();
      expect(_overLinksMenu.buttonDimensions, new ut.isInstanceOf<Rectangle>());
    });

    it('when set to open is open', _testOpen);

    it('when set to closed is closed', () {
      var dropdown = _testOpen();
      _overLinksMenu.isMenuOpen = false;
      expect(dropdown.classes
                     .contains(OverflowedLinksMenuElement.OPEN_DROPDOWN_CLASSNAME))
          .toBeFalse();
    });
  });
}


OverflowedLinksMenuElement _overLinksMenu;

HtmlElement _testOpen() {
  _overLinksMenu.isMenuOpen = true;
  var dropdown = _overLinksMenu.shadowRoot.getElementById('links-dropdown');
  expect(dropdown.classes
                 .contains(OverflowedLinksMenuElement.OPEN_DROPDOWN_CLASSNAME))
      .toBeTrue();
  return dropdown;
}