library overflowed_links_menu_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' as ut;

import 'package:about_me/header/header.dart';

void run() {
  describe('The overflowed links menu', () {
    OverflowedLinksMenuElement overLinksMenu;
    beforeEach(() => overLinksMenu = new OverflowedLinksMenuElement());

    it('has a working element factory constructor', () =>
        expect(() => new OverflowedLinksMenuElement()).not.toThrow());

    it('has an attribute that holds a list of OverflowedLinks', () {
      expect(overLinksMenu.overflowedLinks,
             new ut.isInstanceOf<List<OverflowedHeaderLink>>());
    });

    it('has an attribute that describes whether or not the menu should be open', () {
      expect(() => overLinksMenu.isMenuOpen).not.toThrow();
      expect(overLinksMenu.isMenuOpen, new ut.isInstanceOf<bool>());
    });

    it('has a property for accessing the menu button dimensions', () {
      expect(() => overLinksMenu.buttonDimensions).not.toThrow();
      expect(overLinksMenu.buttonDimensions, new ut.isInstanceOf<Rectangle>());
    });
  });
}