import 'package:polymer/builder.dart';

void main(List<String> args) {
  // Runs the linter, and optionally builds the project for deployment.
  lint(entryPoints: ['index.html'], options: parseOptions(args));
}