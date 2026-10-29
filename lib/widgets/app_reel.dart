import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import 'load_when_near.dart';
import 'on_screen.dart';

/// A short, looping screen recording made from two real screenshots: a phone
/// sways in 3D while the list screen's items pop up as tickets beside it, a
/// finger taps the last one, the detail screen pushes in, a badge stamps
/// onto it, the like button gets tapped, and the app swipes back.
///
/// One [AnimationController] drives everything from a 10 second timeline,
/// and it only runs while the card is on screen.
class AppReelView extends StatefulWidget {
  const AppReelView({super.key, required this.reel, required this.accent});

  final AppReel reel;
  final Color accent;

  @override
  State<AppReelView> createState() => _AppReelViewState();
}

class _AppReelViewState extends State<AppReelView>
    with SingleTickerProviderStateMixin {
  static const _loop = 10.0;

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  void _onScreen(bool visible) {
    if (!mounted) return;
    visible ? _clock.repeat() : _clock.stop();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return OnScreen(
      onChanged: _onScreen,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.35, -0.2),
            radius: 1.1,
            colors: [accent.withValues(alpha: 0.42), const Color(0xff10131b)],
          ),
        ),
        child: LoadWhenNear(
          child: LayoutBuilder(
            builder: (context, c) => AnimatedBuilder(
              animation: _clock,
              builder: (context, _) => _frame(c.biggest, _clock.value * _loop),
            ),
          ),
        ),
      ),
    );
  }

  Widget _frame(Size box, double t) {
    final reel = widget.reel;
    final accent = widget.accent;
    final screenH = box.height * 0.74;
    final screen = Size(screenH * 9 / 16, screenH);

    // Detail screen: pushed in at 3.7 s, popped at 7.8 s.
    final push =
        _seg(t, 3.7, 4.25, Curves.easeOutCubic) -
        _seg(t, 7.8, 8.35, Curves.easeInOutCubic);
    // Fade the whole scene in and out so the loop has no visible seam.
    final fade = _seg(t, 0, 0.5) * (1 - _seg(t, 9.5, 10));

    final phone = SizedBox.fromSize(
      size: screen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screen.width * 0.09),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // List screen, shifted left and dimmed while detail is on top.
            Transform.translate(
              offset: Offset(-screen.width * 0.3 * push, 0),
              child: _shot(reel.list, screen),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.3 * push),
              ),
            ),
            ..._tap(t, 3.15, reel.open, screen),
            Transform.translate(
              offset: Offset(screen.width * (1 - push), 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (push > 0 && push < 1)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 14,
                      ),
                  ],
                ),
                child: _detail(t, screen),
              ),
            ),
          ],
        ),
      ),
    );

    final sway = math.sin(t / _loop * 2 * math.pi);
    final bezel = screen.width * 0.055;
    return Opacity(
      opacity: fade,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Tickets for the list items, rising in one by one.
          Positioned(
            left: box.width * 0.06,
            top: 0,
            bottom: 0,
            width: box.width * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < reel.items.length; i++)
                  _ticket(t, i, box.height),
              ],
            ),
          ),
          if (reel.chip case final chip?)
            Positioned(
              left: box.width * 0.06,
              bottom: box.height * 0.08,
              child: _chip(chip, box.height),
            ),
          Align(
            alignment: const Alignment(0.5, 0.05),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014)
                ..rotateY(-0.32 + 0.1 * sway)
                ..rotateX(0.08)
                ..rotateZ(0.03),
              child: Container(
                padding: EdgeInsets.all(bezel),
                decoration: BoxDecoration(
                  color: const Color(0xff0c0d10),
                  borderRadius: BorderRadius.circular(
                    screen.width * 0.09 + bezel,
                  ),
                  border: Border.all(color: Colors.white24, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: phone,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The detail screen: the product slowly zooms, the badge stamps on, and
  /// the like button is tapped.
  Widget _detail(double t, Size screen) {
    final reel = widget.reel;
    final zoom = 1 + 0.05 * _seg(t, 4.2, 7.8, Curves.easeInOut);
    final stamp = _seg(t, 5.0, 5.45, Curves.easeOutBack);
    final shock = _seg(t, 5.15, 5.9, Curves.easeOut);
    final liked = t >= 6.55 && t < 8.4;
    final pop = _seg(t, 6.55, 6.95, Curves.elasticOut);
    final plusOne = _seg(t, 6.6, 7.6, Curves.easeOut);
    final like = Offset(
      reel.like.dx * screen.width,
      reel.like.dy * screen.height,
    );
    final stampAt = Offset(screen.width * 0.72, screen.height * 0.27);
    return SizedBox.fromSize(
      size: screen,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _shot(reel.detail, screen),
          // Only the product photo zooms; the bar and text stay put.
          Positioned(
            left: 0,
            right: 0,
            top: screen.height * 0.2,
            height: screen.height * 0.43,
            child: ClipRect(
              child: Transform.scale(
                scale: zoom,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: screen.height,
                  child: Transform.translate(
                    offset: Offset(0, -screen.height * 0.2),
                    child: _shot(reel.detail, screen),
                  ),
                ),
              ),
            ),
          ),
          if (shock > 0 && shock < 1)
            Positioned(
              left: stampAt.dx - screen.width * 0.25,
              top: stampAt.dy - screen.width * 0.25,
              child: Opacity(
                opacity: 1 - shock,
                child: Container(
                  width: screen.width * 0.5,
                  height: screen.width * 0.5,
                  transform: Matrix4.diagonal3Values(
                    0.4 + shock,
                    0.4 + shock,
                    1,
                  ),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.accent, width: 2),
                  ),
                ),
              ),
            ),
          if (stamp > 0)
            Positioned(
              left: stampAt.dx,
              top: stampAt.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.rotate(
                  angle: -0.22,
                  child: Transform.scale(
                    scale: 2.4 - 1.4 * stamp,
                    child: Opacity(
                      opacity: _seg(t, 5.0, 5.15),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screen.width * 0.05,
                          vertical: screen.width * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accent,
                          borderRadius: BorderRadius.circular(
                            screen.width * 0.03,
                          ),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 8),
                          ],
                        ),
                        child: Text(
                          reel.stamp,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: screen.width * 0.11,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ..._tap(t, 6.3, reel.like, screen),
          if (liked)
            Positioned(
              left: like.dx,
              top: like.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.scale(
                  scale: pop,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: widget.accent,
                    size: screen.width * 0.075,
                  ),
                ),
              ),
            ),
          if (plusOne > 0 && plusOne < 1)
            Positioned(
              left: like.dx,
              top: like.dy - screen.height * 0.1 * plusOne,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -1.2),
                child: Opacity(
                  opacity: 1 - plusOne,
                  child: Text(
                    '+1',
                    style: TextStyle(
                      color: widget.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: screen.width * 0.08,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A fingertip that lands at [at] (fractions of the screen) and ripples.
  List<Widget> _tap(double t, double start, Offset at, Size screen) {
    final land = _seg(t, start - 0.35, start, Curves.easeOut);
    final ripple = _seg(t, start, start + 0.55, Curves.easeOut);
    final lift = _seg(t, start + 0.15, start + 0.5);
    if (land == 0 || lift == 1) return const [];
    final c = Offset(at.dx * screen.width, at.dy * screen.height);
    final r = screen.width * 0.09;
    final rippleR = r * (0.6 + 1.8 * ripple);
    return [
      if (ripple > 0)
        Positioned(
          left: c.dx - rippleR,
          top: c.dy - rippleR,
          child: Container(
            width: rippleR * 2,
            height: rippleR * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.35 * (1 - ripple)),
            ),
          ),
        ),
      Positioned(
        left: c.dx - r,
        top: c.dy - r,
        child: Opacity(
          opacity: land * (1 - lift),
          child: Transform.scale(
            scale: 1.25 - 0.25 * land,
            child: Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.55),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _ticket(double t, int i, double boxH) {
    final (label, name) = widget.reel.items[i];
    final opened = i == widget.reel.items.length - 1;
    final enter = _seg(t, 0.8 + i * 0.75, 1.35 + i * 0.75, Curves.easeOutBack);
    // The opened item lights up when the finger taps it.
    final glow = opened ? _seg(t, 3.15, 3.4) * (1 - _seg(t, 8.4, 9.0)) : 0.0;
    final size = boxH * 0.058;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: boxH * 0.022),
      child: Opacity(
        opacity: enter.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, boxH * 0.08 * (1 - enter)),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              size * 0.35,
              size * 0.3,
              size * 0.7,
              size * 0.3,
            ),
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.black.withValues(alpha: 0.45),
                widget.accent.withValues(alpha: 0.3),
                glow,
              ),
              borderRadius: BorderRadius.circular(size),
              border: Border.all(
                color: Color.lerp(Colors.white24, widget.accent, glow)!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size * 0.4,
                    vertical: size * 0.12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accent,
                    borderRadius: BorderRadius.circular(size),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.82,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: size * 0.45),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: size * 0.85,
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

  Widget _chip(String text, double boxH) {
    final size = boxH * 0.055;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.55,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: size, color: Colors.white70),
          SizedBox(width: size * 0.3),
          Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              fontSize: size * 0.8,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shot(String asset, Size screen) => Image.asset(
    asset,
    width: screen.width,
    height: screen.height,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
  );

  /// Progress of [t] through the span [a]..[b], as 0..1 through [curve].
  static double _seg(
    double t,
    double a,
    double b, [
    Curve curve = Curves.linear,
  ]) => curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
}
