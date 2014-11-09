part of about_me_tests;

void runElementStyleRangeEvaluatorTests() {
  describe('The element style range evaluator',
           () => new _ElementStyleRangeEvaluatorTests());
}

class _ElementStyleRangeEvaluatorTests {
  ElStyleMeasurerBase _testEvaluator;
  StyleElement _style;
  _ElementStyleRangeEvaluatorTests() {
    describe('top range method', () {
      beforeEach(() => _testEvaluator = new TopStyleMeasurer(new Element.div()));
      it('should exist', () =>
         expect(() => _testEvaluator.measureClassRange('foo', 'bar')).not.toThrow());
      it('should return an interval of 0 for non-existant css classes', () =>
         expect(_testEvaluator.measureClassRange('foo', 'bar').range).toEqual(0));

      beforeEach(() {
        var div = new Element.div();
        div.id = 'style-range-test-div';
        div.style.position = 'absolute';
        document.body.append(div);
        _testEvaluator = new TopStyleMeasurer(div);

        _style = new StyleElement();
        document.body.append(_style);
      });

      afterEach(_afterEach);

      it('should return a min/max value of 1 for a min/max top value of 1',
         _minTopIs1);
    });

    describe('height range method', () {
      beforeEach(() => _testEvaluator = new HeightStyleMeasurer(new Element.div()));
      it('should exist', () => 
         expect(() => _testEvaluator.measureClassRange('foo', 'bar')).not.toThrow());
      it('should return an interval of 0 for non-existant css classes', () =>
         expect(_testEvaluator.measureClassRange('foo', 'bar').range).toEqual(0));
      
      beforeEach(() {
        var div = new Element.div();
        div.id = 'style-range-test-div';
        div.style.position = 'absolute';
        document.body.append(div);
        _testEvaluator = new HeightStyleMeasurer(div);

        _style = new StyleElement();
        document.body.append(_style);
      });

      afterEach(_afterEach);
      it('should return a min/max value of 1 for a min/max top value of 1',
         _minHeightIs1);
      it('should return a range of 1 for min of 0 and max of 1', _rangeHeightIs1);
    });
    
    beforeEach(() {
      var div = new Element.div();
      div.id = 'style-range-test-div';
      div.style.position = 'absolute';
      document.body.append(div);
      _testEvaluator = new HeightStyleMeasurer(div);

      _style = new StyleElement();
      document.body.append(_style);
    });
    afterEach(_afterEach);
    
    it('should handle elements with transitions', () {
      var divEl = document.getElementById('style-range-test-div');
      divEl.style.transitionDuration = '1000ms';
      _rangeHeightIs1();
    });
  }

  void _afterEach() {
    document.getElementById('style-range-test-div').remove();
    _style.remove();
  }

  void _minTopIs1() {
    _style.appendText('.foo { top: 1px } .bar { top: 1px }');
    var inter = _testEvaluator.measureClassRange('foo', 'bar');
    expect(inter.min).toEqual(1);
    expect(inter.max).toEqual(1);
  }

  void _rangeTopIs1() {
    _style.appendText('.foo { top: 0px } .bar { top: 1px }');
    expect(_testEvaluator.measureClassRange('foo', 'bar').range).toEqual(1);
  }

  void _minHeightIs1() {
    _style.appendText('.foo { height: 1px } .bar { height: 1px }');
    var inter = _testEvaluator.measureClassRange('foo', 'bar');
    expect(inter.min).toEqual(1);
    expect(inter.max).toEqual(1);
  }

  void _rangeHeightIs1() {
    _style.appendText('.foo { height: 0px } .bar { height: 1px }');
    expect(_testEvaluator.measureClassRange('foo', 'bar').range).toEqual(1);
  }
}