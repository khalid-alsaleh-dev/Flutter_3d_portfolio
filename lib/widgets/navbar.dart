import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/portfolio_data.dart';
import '../utils/custom_colors.dart';
import '../utils/image_assets.dart';
import '../audio/sound_toggle.dart';
import '../utils/launch.dart';

class NavItem {
  const NavItem(this.label, this.key);
  final String label;
  final GlobalKey key;
}

/// Top bar: transparent over the hero, frosted glass once you scroll. The
/// bottom edge doubles as a katana-shaped reading progress bar.
class Navbar extends StatefulWidget {
  const Navbar({
    super.key,
    required this.items,
    required this.active,
    required this.progress,
    required this.onSelect,
  });

  final List<NavItem> items;
  final ValueListenable<int> active;
  final ValueListenable<double> progress;
  final ValueChanged<int> onSelect;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _menuOpen = false;

  void _select(int i) {
    setState(() => _menuOpen = false);
    widget.onSelect(i);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1100;
    return ValueListenableBuilder<double>(
      valueListenable: widget.progress,
      builder: (context, progress, _) {
        final solid = progress > 0.004 || _menuOpen;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // No BackdropFilter: the scene behind animates every frame, so a
            // backdrop blur would be recomputed constantly. A dense tint reads
            // the same over this dark background at a fraction of the cost.
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 76,
              padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 48),
              color: solid
                  ? CustomColors.darkBackground.withValues(alpha: 0.88)
                  : Colors.transparent,
              child: Row(
                children: [
                  _Logo(onTap: () => _select(0)),
                  const Spacer(),
                  if (!compact) ...[
                    ValueListenableBuilder<int>(
                      valueListenable: widget.active,
                      builder: (context, active, _) => Row(
                        children: [
                          for (var i = 0; i < widget.items.length; i++)
                            _NavLink(
                              label: widget.items[i].label,
                              active: i == active,
                              onTap: () => _select(i),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    const _Socials(),
                    const SizedBox(width: 8),
                    const SoundToggle(),
                  ] else ...[
                    const SoundToggle(),
                    IconButton(
                      onPressed: () => setState(() => _menuOpen = !_menuOpen),
                      icon: Icon(
                        _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _ProgressBlade(progress: progress),
            if (compact && _menuOpen) _mobileMenu(context),
          ],
        );
      },
    );
  }

  Widget _mobileMenu(BuildContext context) {
    return Container(
      width: double.infinity,
      color: CustomColors.darkBackground.withValues(alpha: 0.96),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            TextButton(
                  onPressed: () => _select(i),
                  child: Text(
                    widget.items[i].label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: (i * 60).ms)
                .slideX(begin: -0.2, delay: (i * 60).ms),
          const SizedBox(height: 16),
          const _Socials(),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(ImageAssets.logo, height: 26),
          const SizedBox(width: 10),
          const Text(
            PortfolioData.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            PortfolioData.surname,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lit = _hover || widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: lit
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: lit ? 26 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: widget.active
                      ? CustomColors.primary
                      : CustomColors.secondary,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (widget.active
                                  ? CustomColors.primary
                                  : CustomColors.secondary)
                              .withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Socials extends StatelessWidget {
  const _Socials();

  @override
  Widget build(BuildContext context) {
    Widget icon(String asset, String tooltip, String url) => Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => openUrl(url),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(asset, width: 22, height: 22),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon(ImageAssets.github, 'GitHub', Links.github),
        icon(ImageAssets.linkedin, 'LinkedIn', Links.linkedin),
        icon(ImageAssets.facebook, 'Facebook', Links.facebook),
      ],
    );
  }
}

/// Reading progress drawn as a blade with a glowing tip.
class _ProgressBlade extends StatelessWidget {
  const _ProgressBlade({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: CustomPaint(painter: _ProgressPainter(progress)),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final end = size.width * progress.clamp(0.0, 1.0);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(end - 14, 0)
      ..lineTo(end, size.height / 2)
      ..lineTo(end - 14, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            CustomColors.secondary.withValues(alpha: 0.6),
            CustomColors.steel,
            Colors.white,
          ],
          stops: const [0, 0.85, 1],
        ).createShader(Rect.fromLTWH(0, 0, end, size.height)),
    );
    final tip = Offset(end, size.height / 2);
    canvas.drawCircle(
      tip,
      9,
      Paint()
        ..shader = RadialGradient(
          colors: [
            CustomColors.primary.withValues(alpha: 0.85),
            CustomColors.primary.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: tip, radius: 9)),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) =>
      old.progress != progress;
}
