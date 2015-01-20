import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'package:polymer/polymer.dart';

const String TAG_NAME = 'dkp-skills';
@CustomTag(TAG_NAME)
class SkillsElement extends PolymerElement {
  factory SkillsElement() {
    return new Element.tag(TAG_NAME);
  }

  @override
  SkillsElement.created() : super.created();

  @override
  void attached() {
    super.attached();
    if (document.readyState == 'complete') {
      new LangsChart().render(shadowRoot);
    } else {
      StreamSubscription winOnLoad;
      winOnLoad = window.onLoad.listen((_) {
        new LangsChart().render(shadowRoot);
        winOnLoad.cancel();
      });
    }
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

  void _renderTo(HtmlElement el) {
    _chartOptions['chart']['renderTo'] = el;
    var jsChartOptions = new js.JsObject.jsify(_chartOptions);
    new js.JsObject(js.context['Highcharts']['Chart'], [jsChartOptions]);
  }
}

class LangsChart extends SkillsChart {
  static const _CATEGORIES = const [
    'Dart', 'C', 'JS', 'C++', 'Java', 'C#'
  ];

  static const _RELATIVE_EXP = const [
    5, 4, 3, 3, 3, 3
  ];

  static const _YEARS = const [
    2, 3, 3, 3, 2, 2
  ];

  LangsChart() : super(_CATEGORIES, _RELATIVE_EXP, _YEARS);

  void render(ShadowRoot shadowRoot) {
    _renderTo(shadowRoot.getElementById('languages-chart'));
  }
}

//class PlatformsChart extends SkillsChart {
//  static const _CATEGORIES = const [
//    'HTML5', 'Polymer.dart', 'Angular.dart', 'Rails', 'Android'
//  ];
//
//  static const _RELATIVE_EXP = const [
//    5, 4, 3, 2, 3
//  ];
//
//  static const _YEARS = const [
//    3, 2, 1, 2, 2
//  ];
//}
