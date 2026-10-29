import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../utils/custom_colors.dart';
import 'load_when_near.dart';
import 'on_screen.dart';
import 'site_preview.dart';

/// A looping screen recording made from a single website screenshot (see
/// [FormReel]): the cursor clicks the connect button, the view zooms in on
/// the form, each field is typed in, the form is sent and a confirmation
/// pops up, then the view zooms back out.
///
/// The screenshot and everything drawn onto it sit under one "camera"
/// transform; the cursor and the toast stay at screen size, like a real
/// recording. One controller drives it all and only runs while on screen.
class FormReelView extends StatefulWidget {
  const FormReelView({
    super.key,
    required this.reel,
    required this.host,
    required this.accent,
  });

  final FormReel reel;
  final String host;
  final Color accent;

  @override
  State<FormReelView> createState() => _FormReelViewState();
}

class _FormReelViewState extends State<FormReelView>
    with SingleTickerProviderStateMixin {
  static const _loop = 11.0;

  /// When the cursor reaches field i; it types for [_typing] seconds there.
  static double _fieldAt(int i) => 3.0 + i * 0.95;
  static const _typing = 0.6;

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 11000),
  );

  late final double _submitAt = _fieldAt(widget.reel.fields.length) + 0.2;
  late final List<(double, Offset)> _path = _cursorPath();

  void _onScreen(bool visible) {
    if (!mounted) return;
    visible ? _clock.repeat() : _clock.stop();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  /// Cursor keyframes, in screenshot fractions.
  List<(double, Offset)> _cursorPath() {
    final reel = widget.reel;
    final rest = const Offset(0.3, 0.85);
    final fields = reel.fields;
    Offset inField(Rect r) => Offset(r.left + r.width * 0.3, r.center.dy);
    return [
      (0.0, rest),
      (0.5, rest),
      (1.4, reel.connect.center),
      (2.3, reel.connect.center),
      for (var i = 0; i < fields.length; i++) ...[
        (_fieldAt(i), inField(fields[i].$1)),
        (_fieldAt(i) + _typing + 0.1, inField(fields[i].$1)),
      ],
      (_submitAt - 0.1, reel.submit.center),
      (_submitAt + 1.2, reel.submit.center),
      (9.4, const Offset(0.84, 0.86)),
      (_loop, const Offset(0.84, 0.86)),
    ];
  }

  Offset _cursorAt(double t) {
    for (var i = 1; i < _path.length; i++) {
      final (t1, p1) = _path[i];
      if (t <= t1) {
        final (t0, p0) = _path[i - 1];
        final k = Curves.easeInOutCubic.transform(
          t1 == t0 ? 1 : ((t - t0) / (t1 - t0)).clamp(0.0, 1.0),
        );
        return Offset.lerp(p0, p1, k)!;
      }
    }
    return _path.last.$2;
  }

  @override
  Widget build(BuildContext context) {
    return OnScreen(
      onChanged: _onScreen,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              widget.accent.withValues(alpha: 0.35),
              const Color(0xff10131b),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Column(
              children: [
                BrowserBar(host: widget.host),
                Expanded(
                  child: ColoredBox(
                    color: _background,
                    child: LoadWhenNear(
                      child: LayoutBuilder(
                        builder: (context, c) => AnimatedBuilder(
                          animation: _clock,
                          builder: (context, _) =>
                              _frame(c.biggest, _clock.value * _loop),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _frame(Size view, double t) {
    final reel = widget.reel;
    final page = Size(view.width, view.width * reel.aspect);

    // Camera: zoom in on the form while it is filled in, then back out.
    final formArea = reel.fields
        .map((f) => f.$1)
        .fold(reel.submit, (a, b) => a.expandToInclude(b));
    final zoomIn =
        _seg(t, 2.2, 3.0, Curves.easeInOutCubic) -
        _seg(t, _submitAt + 1.2, _submitAt + 2.0, Curves.easeInOutCubic);
    final zoom = 1 + 0.75 * zoomIn;
    final focus = Offset(
      formArea.center.dx * page.width,
      formArea.center.dy * page.height,
    );
    // At full zoom the form's centre sits in the middle of the view.
    final target = Offset(view.width / 2, view.height / 2) - focus * zoom;
    final pan = Offset.lerp(Offset.zero, target, zoomIn)!;
    Offset toView(Offset frac) =>
        Offset(frac.dx * page.width, frac.dy * page.height) * zoom + pan;

    final fade = _seg(t, 0, 0.4) * (1 - _seg(t, _loop - 0.5, _loop));
    final cursor = toView(_cursorAt(t));
    final press = _press(t);
    final toast =
        _seg(t, _submitAt + 0.75, _submitAt + 1.1, Curves.easeOutBack) *
        (1 - _seg(t, _loop - 1.0, _loop - 0.6));

    // An explicit clip: the Stack's own clip only applies when it sees
    // overflow, and a zoomed (transformed) page doesn't count as overflow.
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Transform(
              transform: Matrix4.identity()
                ..translateByDouble(pan.dx, pan.dy, 0, 1)
                ..scaleByDouble(zoom, zoom, 1, 1),
              child: SizedBox.fromSize(size: page, child: _page(t, page)),
            ),
          ),
          // Click ripple, at screen size.
          if (press.$2 > 0 && press.$2 < 1)
            Positioned(
              left: cursor.dx - 14,
              top: cursor.dy - 14,
              child: Opacity(
                opacity: 1 - press.$2,
                child: Container(
                  width: 28,
                  height: 28,
                  transform: Matrix4.diagonal3Values(
                    0.3 + press.$2,
                    0.3 + press.$2,
                    1,
                  ),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            left: cursor.dx - 1,
            top: cursor.dy - 1,
            child: Transform.scale(
              scale: 1 - 0.15 * press.$1,
              alignment: Alignment.topLeft,
              child: const CustomPaint(
                size: Size(13, 19),
                painter: _CursorPainter(),
              ),
            ),
          ),
          if (toast > 0)
            Positioned(
              top: 8,
              right: 8 - (1 - toast) * 40,
              child: Opacity(
                opacity: toast.clamp(0.0, 1.0),
                child: _toast(reel.done),
              ),
            ),
          // The loop fades in and out of the page background.
          if (fade < 1)
            Positioned.fill(
              child: ColoredBox(color: _background.withValues(alpha: 1 - fade)),
            ),
        ],
      ),
    );
  }

  static const _background = Color(0xff0f0e13);

  /// The screenshot plus everything drawn onto it, in page coordinates.
  Widget _page(double t, Size page) {
    final reel = widget.reel;
    final colors = reel.colors;
    Rect at(Rect r) => Rect.fromLTRB(
      r.left * page.width,
      r.top * page.height,
      r.right * page.width,
      r.bottom * page.height,
    );
    final connected = t >= 1.6;
    final badge = _seg(t, 1.8, 2.2);
    final sending = t >= _submitAt + 0.05 && t < _submitAt + 0.75;
    final sent = t >= _submitAt + 0.75;
    final progress = _seg(t, _submitAt + 0.05, _submitAt + 0.75);
    final shine = _seg(t, _submitAt + 0.8, _submitAt + 1.6, Curves.easeInOut);

    final submit = at(reel.submit);
    final connect = at(reel.connect);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          reel.shot,
          width: page.width,
          height: page.height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.medium,
        ),
        if (connected)
          Positioned.fromRect(
            rect: connect,
            child: _pill(
              colors.button,
              connect.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: connect.height * 0.22,
                    height: connect.height * 0.22,
                    decoration: const BoxDecoration(
                      color: CustomColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: connect.height * 0.2),
                  _label(reel.connected, connect.height * 0.36),
                ],
              ),
            ),
          ),
        if (badge > 0)
          Positioned.fromRect(
            rect: at(reel.badge),
            child: Opacity(
              opacity: badge,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _label(reel.connected, at(reel.badge).height * 0.75),
              ),
            ),
          ),
        if (reel.shine case final area? when shine > 0 && shine < 1)
          Positioned.fromRect(
            rect: at(area),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(at(area).height * 0.06),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-3 + 5 * shine, -1),
                    end: Alignment(-1 + 5 * shine, 1),
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        for (var i = 0; i < reel.fields.length; i++)
          if (_typed(t, i) case final text?)
            Positioned.fromRect(
              rect: at(reel.fields[i].$1),
              child: ColoredBox(
                color: colors.field,
                child: Padding(
                  padding: EdgeInsets.only(left: page.width * 0.0045),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _label(
                          text,
                          at(reel.fields[i].$1).height * 0.4,
                          weight: FontWeight.w400,
                        ),
                        if (_caret(t, i))
                          Container(
                            width: 1,
                            height: at(reel.fields[i].$1).height * 0.45,
                            margin: const EdgeInsets.only(left: 1),
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        if (sending || sent)
          Positioned.fromRect(
            rect: submit,
            child: _pill(
              sent ? colors.button : colors.panel,
              submit.height,
              Stack(
                alignment: Alignment.center,
                children: [
                  if (sending)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: submit.width * progress,
                        height: submit.height * 0.08,
                        color: colors.button,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (sent) ...[
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: submit.height * 0.5,
                        ),
                        SizedBox(width: submit.height * 0.12),
                      ],
                      _label(sent ? 'Sent' : 'Sending…', submit.height * 0.36),
                    ],
                  ),
                ],
              ),
              border: !sent,
            ),
          ),
      ],
    );
  }

  /// What is typed into field [i] at [t], or null before typing starts.
  /// Cleared at the end of the loop.
  String? _typed(double t, int i) {
    final start = _fieldAt(i) + 0.1;
    if (t < start || t > _loop - 0.5) return null;
    final text = widget.reel.fields[i].$2;
    final n = (text.length * _seg(t, start, start + _typing)).ceil();
    return text.substring(0, n);
  }

  bool _caret(double t, int i) {
    final start = _fieldAt(i) + 0.1;
    final end = _fieldAt(i + 1) - 0.05;
    return t >= start && t < end && (t * 2.5).floor().isEven;
  }

  /// How far the button is held down (0..1) and the ripple after a click.
  (double, double) _press(double t) {
    var down = 0.0, ripple = 0.0;
    for (final at in [1.5, _submitAt]) {
      down = math.max(
        down,
        _seg(t, at - 0.08, at) * (1 - _seg(t, at + 0.05, at + 0.15)),
      );
      final r = _seg(t, at, at + 0.45, Curves.easeOut);
      if (r > 0 && r < 1) ripple = r;
    }
    return (down, ripple);
  }

  Widget _pill(
    Color color,
    double height,
    Widget child, {
    bool border = false,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
        border: border ? Border.all(color: Colors.white38, width: 0.6) : null,
      ),
      child: child,
    );
  }

  static Widget _label(
    String text,
    double size, {
    FontWeight weight = FontWeight.w600,
  }) => Text(
    text,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.clip,
    style: TextStyle(
      color: Colors.white,
      fontSize: size,
      fontWeight: weight,
      height: 1.1,
    ),
  );

  Widget _toast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xee14161f),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: CustomColors.primary.withValues(alpha: 0.7)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: CustomColors.primary,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  /// Progress of [t] through the span [a]..[b], as 0..1 through [curve].
  static double _seg(
    double t,
    double a,
    double b, [
    Curve curve = Curves.linear,
  ]) => curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
}

/// A classic arrow pointer.
class _CursorPainter extends CustomPainter {
  const _CursorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final arrow = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h * 0.82)
      ..lineTo(w * 0.3, h * 0.62)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.68, h * 0.92)
      ..lineTo(w * 0.48, h * 0.56)
      ..lineTo(w, h * 0.56)
      ..close();
    canvas.drawShadow(arrow, Colors.black, 2, false);
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CursorPainter oldDelegate) => false;
}
