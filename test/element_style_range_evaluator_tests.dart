part of about_me_tests;

void runElementStyleRangeEvaluatorTests() {
  describe('The element style range evaluator',
           () => new _ElementStyleRangeEvaluatorTests());
}

class _ElementStyleRangeEvaluatorTests {
  ElementStyleRangeEvaluator _testEvaluator;
  _ElementStyleRangeEvaluatorTests() {
    beforeEach(() => _testEvaluator = new ElementStyleRangeEvaluator(new Element.div()));
    describe('the top range method', () {
      it('should exist',
         _topRangeForTwoClasses);
      it('should return an interval of 0 for non-existant css classes', () {
        expect(_testEvaluator.evalTop('foo', 'bar').range).toEqual(0);
      });
      it('should return a min interval equal to that of the min class',
         _minIntervalEqualToMinClass);
    });
  }

  void _topRangeForTwoClasses() {
    expect(() => _testEvaluator.evalTop('foo', 'bar')).not.toThrow();
  }

  void _minIntervalEqualToMinClass() {
    var div = new Element.div();
    document.body.append(div);
    _testEvaluator = new ElementStyleRangeEvaluator(div);
    var style = new StyleElement();
    style.appendText('.foo { top: 5px }');
    document.body.append(style);
    expect(_testEvaluator.evalTop('foo', 'bar').min).toEqual(5);
  }
}