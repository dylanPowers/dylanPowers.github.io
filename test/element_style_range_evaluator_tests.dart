part of about_me_tests;

void runElementStyleRangeEvaluatorTests() {
  describe('The element style range evaluator',
           () => new _ElementStyleRangeEvaluatorTests());
}

class _ElementStyleRangeEvaluatorTests {
  ElementStyleRangeEvaluator _testEvaluator;
  StyleElement _style;
  _ElementStyleRangeEvaluatorTests() {
    beforeEach(() => _testEvaluator = new ElementStyleRangeEvaluator(new Element.div()));
    describe('top range method', () {
      it('should exist', () =>
         expect(() => _testEvaluator.evalTop('foo', 'bar')).not.toThrow());
      it('should return an interval of 0 for non-existant css classes', () =>
         expect(_testEvaluator.evalTop('foo', 'bar').range).toEqual(0));

      beforeEach(_beforeEach);
      afterEach(_afterEach);
      it('should return a min/max value of 1 for a min/max top value of 1',
         _minTopIs1);
    });

    describe('height range method', () {
      it('should exist', () => 
         expect(() => _testEvaluator.evalHeight('foo', 'bar')).not.toThrow());
      it('should return an interval of 0 for non-existant css classes', () =>
         expect(_testEvaluator.evalHeight('foo', 'bar').range).toEqual(0));
      
      beforeEach(_beforeEach);
      afterEach(_afterEach);
      it('should return a min/max value of 1 for a min/max top value of 1',
         _minHeightIs1);
      it('should return a range of 1 for min of 0 and max of 1', _rangeHeightIs1);
    });
  }

  void _beforeEach() {
    var div = new Element.div();
    div.id = 'style-range-test-div';
    div.style.position = 'absolute';
    document.body.append(div);
    _testEvaluator = new ElementStyleRangeEvaluator(div);

    _style = new StyleElement();
    document.body.append(_style);
  }

  void _afterEach() {
    document.getElementById('style-range-test-div').remove();
    _style.remove();
  }

  void _minTopIs1() {
    _style.appendText('.foo { top: 1px } .bar { top: 1px }');
    var inter = _testEvaluator.evalTop('foo', 'bar');
    expect(inter.min).toEqual(1);
    expect(inter.max).toEqual(1);
  }

  void _rangeTopIs1() {
    _style.appendText('.foo { top: 0px } .bar { top: 1px }');
    expect(_testEvaluator.evalTop('foo', 'bar').range).toEqual(1);
  }

  void _minHeightIs1() {
    _style.appendText('.foo { height: 1px } .bar { height: 1px }');
    var inter = _testEvaluator.evalHeight('foo', 'bar');
    expect(inter.min).toEqual(1);
    expect(inter.max).toEqual(1);
  }

  void _rangeHeightIs1() {
    _style.appendText('.foo { height: 0px } .bar { height: 1px }');
    expect(_testEvaluator.evalHeight('foo', 'bar').range).toEqual(1);
  }
}