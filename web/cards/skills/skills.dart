import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'package:polymer/polymer.dart';

const String TAG_NAME = 'dkp-skills';
@CustomTag(TAG_NAME)
class SkillsElement extends PolymerElement {
  static const LANGS_CHART_ID = 'languages-chart';
  static const PLATFORMS_CHART_ID = 'platforms-chart';
  static const TOOLS_CHART_ID = 'tools-chart';

  factory SkillsElement() {
    return new Element.tag(TAG_NAME);
  }

  @override
  SkillsElement.created() : super.created();

  @override
  void attached() {
    super.attached();
    StreamSubscription winOnLoad;
    winOnLoad = window.onLoad.listen((_) {
      _renderCharts();
      winOnLoad.cancel();
    });
  }

  void _renderCharts() {
    new LangsChart().renderTo(shadowRoot, LANGS_CHART_ID);
    new PlatformsChart().renderTo(shadowRoot, PLATFORMS_CHART_ID);
    new ToolsChart().renderTo(shadowRoot, TOOLS_CHART_ID);
  }
}

class Skill {
  final String name;
  final int relativeExp;
  final double years;

  const Skill(this.name, this.relativeExp, this.years);
}

abstract class SkillsChart {
  Map _chartOptions = {
    'chart': {
      'marginLeft': 80,
      'type': 'bar'
    },
    'colors': ['#FFAB00', '#D50000'],
    'credits': {
      'enabled': false
    },
    'legend': {
      'backgroundColor': '#FFF',
      'borderRadius': 2,
      'floating': false,
      'reversed': true,
      'shadow': true,
      'verticalAlign': 'bottom',
      'y': 0
    },
    'plotOptions': {
      'series': {
        'borderWidth': 0,
        'groupPadding': 0.15,
        'pointPadding': 0
      }
    },
    'title': {
      'text': null
    },
    'yAxis': {
      'labels': {
        'enabled': true
      },
      'min': 0,
      'max': 5,
      'tickInterval': 1,
      'title': {
        'text': null
      }
    }
  };

  final List<Skill> skills;

  SkillsChart(this.skills,
              {Map optionOverrides: const {}}) {
    _chartOptions.addAll({
      'xAxis': { 'categories': skills.map((skill) => skill.name) },
      'series': [{
        'name': 'Years',
        'data': skills.map((skill) => skill.years)
      }, {
        'name': 'Relative Knowledge',
        'data': skills.map((skill) => skill.relativeExp)
      }]
    });

    _chartOptions.addAll(optionOverrides);
  }

  void renderTo(ShadowRoot shadowRoot, String elementId) {
    var el = shadowRoot.getElementById(elementId);
    el.style.setProperty('height', '${48 * skills.length + 90}px');
    _chartOptions['chart']['renderTo'] = el;
    var jsChartOptions = new js.JsObject.jsify(_chartOptions);
    new js.JsObject(js.context['Highcharts']['Chart'], [jsChartOptions]);
  }
}

class LangsChart extends SkillsChart {
  static const _SKILLS = const [
    const Skill('Dart', 5, 3.0),
    const Skill('C', 5, 4.0),
    const Skill('CSS', 5, 3.5),
    const Skill('C++', 3, 3.0),
    const Skill('Bash', 3, 2.0),
    const Skill('Java', 3, 2.0),
    const Skill('C#', 3, 1.0),
    const Skill('JS', 2, 2.0),
    const Skill('Go', 2, 0.5),
    const Skill('Ruby', 1, 1.0),
    const Skill('PHP', 1, 1.0)
  ];

  LangsChart() : super(_SKILLS);
}

class PlatformsChart extends SkillsChart {
  static const _SKILLS = const [
    const Skill('Android SDK', 4, 2.0),
    const Skill('Android NDK', 4, 1.0),
    const Skill('Polymer.dart', 3, 2.0),
    const Skill('Ruby on Rails', 2, 2.0),
    const Skill('Chrome App/Ext', 2, 1.0),
    const Skill('OpenGL', 1, 1.0)
  ];

  PlatformsChart() : super(_SKILLS);
}

class ToolsChart extends SkillsChart {
  static const _SKILLS = const [
    const Skill('Git', 5, 4.0),
    const Skill('Linux', 5, 4.0),
    const Skill('Unit Testing', 3, 2.0),
    const Skill('Docker', 2, 0.5),
  ];

  ToolsChart() : super(_SKILLS);
}
