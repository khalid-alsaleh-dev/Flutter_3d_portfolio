import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../utils/custom_colors.dart';
import '../utils/launch.dart';
import '../widgets/blade_button.dart';
import '../widgets/location_tag.dart';
import '../widgets/section_frame.dart';

/// Full-screen hero. The 3D katana lives in the background layer; this is the
/// text that sits beside it and drifts away as the blade starts its slash.
class Welcome extends StatelessWidget {
  const Welcome({super.key, required this.onSeeWork});

  final VoidCallback onSeeWork;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 900;
    return SizedBox(
      height: size.height,
      child: ScrollProgress(
        builder: (context, p, _) {
          final exit = interval(p, 0.5, 0.85);
          return Stack(
            children: [
              Opacity(
                opacity: 1 - exit,
                child: Transform.translate(
                  offset: Offset(-80 * exit, -120 * exit),
                  child: SectionFrame(
                    child: Align(
                      alignment: compact
                          ? const Alignment(0, -0.45)
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: compact ? size.width : size.width * 0.5,
                        ),
                        child: _HeroText(
                          compact: compact,
                          onSeeWork: onSeeWork,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Opacity(
                  opacity: (1 - exit * 3).clamp(0.0, 1.0),
                  child: const _ScrollHint(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.compact, required this.onSeeWork});
  final bool compact;
  final VoidCallback onSeeWork;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final nameSize = width < 600 ? 64.0 : (width < 1200 ? 92.0 : 120.0);
    final align = compact
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = compact ? TextAlign.center : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 2, color: CustomColors.secondary),
            const SizedBox(width: 12),
            const Text(
              'SHINOBI OF CODE',
              style: TextStyle(
                color: CustomColors.secondary,
                letterSpacing: 6,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
        const SizedBox(height: 18),
        Text(
          "Hi, I'm",
          style: TextStyle(
            color: Colors.white,
            fontSize: nameSize * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.4),
        _SlicedName(text: PortfolioData.name, fontSize: nameSize),
        const SizedBox(height: 8),
        _TypedRoles(fontSize: width < 600 ? 20 : 26, textAlign: textAlign),
        const SizedBox(height: 22),
        Text(
          PortfolioData.tagline,
          textAlign: textAlign,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: width < 600 ? 16 : 19,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 1400.ms, duration: 700.ms),
        const SizedBox(height: 36),
        Wrap(
          spacing: 16,
          runSpacing: 14,
          alignment: compact ? WrapAlignment.center : WrapAlignment.start,
          children: [
            BladeButton(
              label: "Let's chat",
              icon: Icons.arrow_forward_rounded,
              filled: true,
              onPressed: () => sendEmail(subject: 'Hello Khalid!'),
            ),
            BladeButton(label: 'See my work', onPressed: onSeeWork),
          ],
        ).animate().fadeIn(delay: 1700.ms).slideY(begin: 0.3),
        const SizedBox(height: 26),
        const LocationTag().animate().fadeIn(delay: 2000.ms),
      ],
    );
  }
}

/// The name flies in letter by letter, each glyph slashed into place.
class _SlicedName extends StatelessWidget {
  const _SlicedName({required this.text, required this.fontSize});
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: -2,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [
            CustomColors.primary,
            Color(0xffb5ffd3),
            CustomColors.primary,
          ],
        ).createShader(Rect.fromLTWH(0, 0, fontSize * 4, fontSize)),
    );
    // One gradient glow behind the word instead of a blurred shadow per letter.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.5,
          colors: [
            CustomColors.primary.withValues(alpha: 0.22),
            CustomColors.primary.withValues(alpha: 0),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < text.length; i++)
            Text(text[i], style: style)
                .animate(delay: (600 + i * 90).ms)
                .fadeIn(duration: 250.ms)
                .slide(
                  begin: Offset(i.isEven ? -0.6 : 0.6, -0.8),
                  curve: Curves.easeOutBack,
                )
                .rotate(begin: i.isEven ? -0.08 : 0.08)
                .then(delay: 2.seconds)
                .shimmer(duration: 1200.ms, color: Colors.white),
        ],
      ),
    );
  }
}

class _TypedRoles extends StatefulWidget {
  const _TypedRoles({required this.fontSize, required this.textAlign});
  final double fontSize;
  final TextAlign textAlign;

  @override
  State<_TypedRoles> createState() => _TypedRolesState();
}

class _TypedRolesState extends State<_TypedRoles> {
  Timer? _timer;
  int _role = 0;
  int _chars = 0;
  bool _deleting = false;
  int _hold = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 70), (_) => _step());
  }

  void _step() {
    final word = PortfolioData.typedRoles[_role];
    setState(() {
      if (_hold > 0) {
        _hold--;
      } else if (!_deleting && _chars < word.length) {
        _chars++;
        if (_chars == word.length) _hold = 26;
      } else if (!_deleting) {
        _deleting = true;
      } else if (_chars > 0) {
        _chars--;
      } else {
        _deleting = false;
        _role = (_role + 1) % PortfolioData.typedRoles.length;
        _hold = 4;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = PortfolioData.typedRoles[_role].substring(0, _chars);
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '> ',
            style: TextStyle(color: CustomColors.secondary),
          ),
          TextSpan(text: word),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child:
                Container(
                      width: 3,
                      height: widget.fontSize,
                      margin: const EdgeInsets.only(left: 3),
                      color: CustomColors.primary,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeOut(duration: 450.ms),
          ),
        ],
      ),
      textAlign: widget.textAlign,
      style: TextStyle(
        color: Colors.white,
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _ScrollHint extends StatelessWidget {
  const _ScrollHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'SCROLL TO UNSHEATHE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 5,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        Container(
              width: 2,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [CustomColors.primary, Colors.transparent],
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .scaleY(
              begin: 0,
              end: 1,
              alignment: Alignment.topCenter,
              duration: 900.ms,
            )
            .then()
            .fadeOut(duration: 400.ms),
      ],
    ).animate().fadeIn(delay: 2200.ms);
  }
}
