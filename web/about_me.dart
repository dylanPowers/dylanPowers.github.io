import 'package:polymer/polymer.dart';

@CustomTag('about-me')
class AboutMe extends PolymerElement {

  // Until Dartium/Chromium/Chrome supports CSS editing of shadow dom objects
  // all HTML templates will use the global style sheet.
  bool get applyAuthorStyles => true;
  
  AboutMe.created() : super.created();
}