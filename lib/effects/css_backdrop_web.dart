import 'package:web/web.dart' as web;

const bool supported = true;

void setSky(String top, String bottom) {
  final style = web.document.documentElement as web.HTMLElement?;
  style?.style
    ?..setProperty('--sky-top', top)
    ..setProperty('--sky-bottom', bottom);
}
