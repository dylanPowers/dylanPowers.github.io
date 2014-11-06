part of about_me_tests;

void runElementStyleRangeEvaluatorTests() {
  describe('The element style range evaluator',
           () => new _ElementStyleRangeEvaluatorTests());
}

class _ElementStyleRangeEvaluatorTests {
  ElementStyleRangeEvaluator _testEvaluator;
  _ElementStyleRangeEvaluatorTests() {
    beforeEach(() => _testEvaluator = new ElementStyleRangeEvaluator(new Element.div()));
    it('should have a method that calculates the top range for two classes',
       _topRangeForTwoClasses);
  }

  void _topRangeForTwoClasses() {
    expect(() => _testEvaluator.evalTop('foo', 'bar')).not.toThrow();
  }
}