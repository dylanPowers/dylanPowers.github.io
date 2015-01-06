library overflowed_links_menu_tests;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' as ut;

import 'package:about_me/header/header.dart';

void run() {
  describe('The overflowed links menu', () {
    it ('has a working element factory constructor', () =>
        expect(() => new OverflowedLinksMenuElement()).not.toThrow());

    it ('has an attribute that holds a list of OverflowedLinks', () {
      var overLinksMenu = new OverflowedLinksMenuElement();
      expect(overLinksMenu.overflowedLinks,
             new ut.isInstanceOf<List<OverflowedHeaderLink>>());
    });

    it ('has an attribute that describes whether or not the menu should be open', () {
      var overLinksMenu = new OverflowedLinksMenuElement();
      expect(() => overLinksMenu.isMenuOpen).not.toThrow();
      expect(overLinksMenu.isMenuOpen, new ut.isInstanceOf<bool>());
    });
  });
}