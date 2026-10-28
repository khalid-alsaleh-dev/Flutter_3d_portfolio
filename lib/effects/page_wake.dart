import 'dart:async';

import 'package:flutter/widgets.dart';

/// Holds back ambient motion and background downloads until the visitor
/// first touches, scrolls, moves the mouse or presses a key (or a fallback
/// timer fires, see [Home]).
///
/// Every animated frame on the web runs Dart on the main thread, so looping
/// effects that start with the page (the blade scene, the typewriter, pulsing
/// dots) keep the CPU busy while the page is still loading and make it slow to
/// respond. Until the page wakes, those effects show a still frame instead.
abstract final class PageWake {
  static final _awake = Completer<void>();

  static bool get isAwake => _awake.isCompleted;

  /// Completes when the page wakes; already complete afterwards.
  static Future<void> get awake => _awake.future;

  /// Safe to call often, e.g. from every pointer event.
  static void wake() {
    if (!_awake.isCompleted) _awake.complete();
  }
}

/// Builds with `awake: false` until [PageWake] wakes, then with `true`.
class WhenAwake extends StatelessWidget {
  const WhenAwake({super.key, required this.builder});

  final Widget Function(BuildContext context, bool awake) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: PageWake.awake,
      builder: (context, _) => builder(context, PageWake.isAwake),
    );
  }
}
