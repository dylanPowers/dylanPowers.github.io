library element_style_measurer_tests;

import 'dart:html';
import 'package:guinness/guinness.dart';

import 'package:about_me/element_style_measurer.dart';

StyleElement _style;
Element _testEl;
ElStyleMeasurerBase _testMeasurer;

void runElementStyleMeasurerTests() {
  describe('The element style range evaluator', () {
    beforeEach(() {
      _testEl = new Element.div();
      _testEl.id = 'style-range-test-div';
      _testEl.style.position = 'absolute';
      document.body.append(_testEl);

      _style = new StyleElement();
      document.body.append(_style);
    });

    afterEach(() {
      _testEl.remove();
      _style.remove();
    });

    _heightRangeTests();
    _topRangeTests();

    it('should handle elements with transitions', () {
      var divEl = document.getElementById('style-range-test-div');
      divEl.style.transitionDuration = '1000ms';
      _style.appendText('.foo { height: 0px } .bar { height: 1px }');
      expect(_testMeasurer.measureClassRange('foo', 'bar').range).toEqual(1);
    });
  });
}

void _heightRangeTests() {
  describe('height range method', () {
    beforeEach(() => _testMeasurer = new HeightStyleMeasurer(_testEl));

    it('should exist', () =>
       expect(() => _testMeasurer.measureClassRange('foo', 'bar')).not.toThrow());

    it('should return an interval of 0 for non-existant css classes', () =>
       expect(_testMeasurer.measureClassRange('foo', 'bar').range).toEqual(0));

    it('should return a min/max value of 1 for a min/max top value of 1',() {
      _style.appendText('.foo { height: 1px } .bar { height: 1px }');
      var inter = _testMeasurer.measureClassRange('foo', 'bar');
      expect(inter.min).toEqual(1);
      expect(inter.max).toEqual(1);
    });

    it('should return a range of 1 for min of 0 and max of 1', () {
      _style.appendText('.foo { height: 0px } .bar { height: 1px }');
      expect(_testMeasurer.measureClassRange('foo', 'bar').range).toEqual(1);
    });
  });
}

void _topRangeTests() {
  describe('top range method', () {
    beforeEach(() => _testMeasurer = new TopStyleMeasurer(_testEl));

    it('should exist', () =>
       expect(() => _testMeasurer.measureClassRange('foo', 'bar')).not.toThrow());

    it('should return an interval of 0 for non-existant css classes', () =>
       expect(_testMeasurer.measureClassRange('foo', 'bar').range).toEqual(0));

    it('should return a min/max value of 1 for a min/max top value of 1',() {
      _style.appendText('.foo { top: 1px } .bar { top: 1px }');
      var inter = _testMeasurer.measureClassRange('foo', 'bar');
      expect(inter.min).toEqual(1);
      expect(inter.max).toEqual(1);
    });
  });
}