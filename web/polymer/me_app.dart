library me_app;

import 'package:polymer/polymer.dart';

@CustomTag('me-app')
class MeApp extends PolymerElement {

  // Until Dartium/Chromium/Chrome supports CSS editing of shadow dom objects
  // all HTML templates will use the global style sheet.
  bool get applyAuthorStyles => true;
  
  MeApp.created() : super.created();
}