library overflowed_links_menu_tests;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' as ut;

import 'package:about_me/header/header.dart';

void run() {
  describe('The overflowed links menu', () {
    it ('has a working element factory constructor', () =>
        expect(() => new OverflowedLinksMenuElement()).not.toThrow());
  });
}