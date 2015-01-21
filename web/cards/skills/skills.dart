import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'package:polymer/polymer.dart';

const String TAG_NAME = 'dkp-skills';
@CustomTag(TAG_NAME)
class SkillsElement extends PolymerElement {
  static const LANGS_CHART_ID = 'languages-chart';
  static const PLATFORMS_CHART_ID = 'platforms-chart';

  factory SkillsElement() {
    return new Element.tag(TAG_NAME);
  }

  @override
  SkillsElement.created() : super.created();

  @override
  void attached() {
    super.attached();
    if (document.readyState == 'complete') {
      _renderCharts();
    } else {
      StreamSubscription winOnLoad;
      winOnLoad = window.onLoad.listen((_) {
        _renderCharts();
        winOnLoad.cancel();
      });
    }
  }

  void _renderCharts() {
    _renderLangsChart();
    _renderPlatformsChart();
  }

  void _renderLangsChart() {
    new LangsChart().renderTo(shadowRoot, LANGS_CHART_ID);
  }

  void _renderPlatformsChart() {
    new PlatformsChart().renderTo(shadowRoot, PLATFORMS_CHART_ID);
  }
}

abstract class SkillsChart {
  Map _chartOptions = {
    'chart': {
      'type': 'bar'
    },
    'title': {
      'text': null
    },
    'yAxis': {
      'min': 0,
      'max': 5,
      'minTickInterval': 1,
      'title': {
        'text': null
      }
    }
  };

  SkillsChart(List<String> categories, List<int> relativeExp, List<int> years) {
    _chartOptions.addAll({
      'xAxis': { 'categories': categories },
      'series': [{
        'name': 'Years',
        'data': years
      }, {
        'name': 'Relative Knowledge',
        'data': relativeExp
      }]
    });
  }

  void renderTo(ShadowRoot shadowRoot, String elementId) {
    var el = shadowRoot.getElementById(elementId);
    _chartOptions['chart']['renderTo'] = el;
    var jsChartOptions = new js.JsObject.jsify(_chartOptions);
    new js.JsObject(js.context['Highcharts']['Chart'], [jsChartOptions]);
  }
}

class LangsChart extends SkillsChart {
  static const _CATEGORIES = const [
    'Dart', 'C', 'JS', 'C++', 'Java', 'C#', 'Go'
  ];

  static const _RELATIVE_EXP = const [
    5, 4, 3, 3, 3, 3, 1
  ];

  static const _YEARS = const [
    2, 3, 3, 3, 2, 2, 1
  ];

  LangsChart() : super(_CATEGORIES, _RELATIVE_EXP, _YEARS);
}

class PlatformsChart extends SkillsChart {
  static const _CATEGORIES = const [
    'Web', 'Android'
  ];

  static const _RELATIVE_EXP = const [
    5, 3
  ];

  static const _YEARS = const [
    3, 2
  ];

  PlatformsChart() : super(_CATEGORIES, _RELATIVE_EXP, _YEARS);
}
