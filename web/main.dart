import 'package:about_me/header/intro_header.dart';
import 'package:about_me/enhanced_window_on_scroll.dart';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:polymer/polymer.dart';

class AboutMeNGApp extends Module {
  AboutMeNGApp() {
    bind(IntroHeaderElement);
    bind(EnhancedWindowOnScroll);
  }
}

void main() {
  applicationFactory().addModule(new AboutMeNGApp()).run();
  initPolymer();
}