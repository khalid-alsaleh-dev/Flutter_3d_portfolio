import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../audio/sound_fx.dart';
import '../audio/sound_toggle.dart';
import '../data/portfolio_data.dart';
import '../utils/custom_colors.dart';
import '../utils/image_assets.dart';
import '../widgets/project_card.dart';
import 'ninja_game.dart';

/// The playable projects section: each project hangs behind a metal plate on
/// chains, and the ninja has to cut the chains to reveal it.
class Dojo extends StatefulWidget {
  const Dojo({super.key});

  @override
  State<Dojo> createState() => _DojoState();
}

class _DojoState extends State<Dojo> {
  /// Created the first time the dojo scrolls into view, so its sprites are not
  /// downloaded and decoded during the initial page load.
  NinjaGame? _game;
  final _focus = FocusNode(debugLabel: 'dojo');

  @override
  void dispose() {
    _focus.dispose();
    SoundFx.wantMusic(false);
    super.dispose();
  }

  void _visibility(VisibilityInfo info) {
    if (!mounted) return;
    if (_game == null) {
      if (info.visibleFraction > 0) {
        setState(
          () => _game = NinjaGame(plateCount: PortfolioData.projects.length),
        );
      }
      return;
    }
    final game = _game!;
    // Stop the game loop entirely while the dojo is off screen.
    if (info.visibleFraction == 0) {
      if (!game.paused) game.pauseEngine();
    } else if (game.paused) {
      game.resumeEngine();
    }
    final active = info.visibleFraction > 0.55;
    if (active == game.active) return;
    game.active = active;
    if (active) {
      _focus.requestFocus();
      SoundFx.wantMusic(true);
    } else {
      _focus.unfocus();
      SoundFx.wantMusic(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return VisibilityDetector(
      key: const Key('dojo'),
      onVisibilityChanged: _visibility,
      child: Container(
        height: 940,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: CustomColors.glassBorder),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.15),
              CustomColors.primary.withValues(alpha: 0.04),
            ],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: game == null
            ? const Center(
                child: Text(
                  'Lighting the dojo...',
                  style: TextStyle(color: Colors.white38, letterSpacing: 3),
                ),
              )
            : MouseRegion(
                onEnter: (_) {
                  if (game.active) _focus.requestFocus();
                },
                child: GameWidget<NinjaGame>(
                  game: game,
                  focusNode: _focus,
                  autofocus: false,
                  initialActiveOverlays: const ['plates', 'hud'],
                  overlayBuilderMap: {
                    'plates': (context, game) => _Plates(game: game),
                    'hud': (context, game) => _Hud(game: game),
                  },
                ),
              ),
      ),
    );
  }
}

class _Plates extends StatelessWidget {
  const _Plates({required this.game});
  final NinjaGame game;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = game.plateCount;
        final width = (c.maxWidth / (count + 1)) * 0.86;
        final cardWidth = width.clamp(240.0, 330.0);
        return Stack(
          children: [
            for (var i = 0; i < count; i++)
              Positioned(
                left: c.maxWidth * (i + 1) / (count + 1) - cardWidth / 2,
                top: 0,
                width: cardWidth,
                child: _HangingProject(
                  game: game,
                  index: i,
                  project: PortfolioData.projects[i],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HangingProject extends StatelessWidget {
  const _HangingProject({
    required this.game,
    required this.index,
    required this.project,
  });
  final NinjaGame game;
  final int index;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.cut[index],
      builder: (context, isCut, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // The project itself, waiting behind the plate.
            Padding(
              padding: const EdgeInsets.only(top: 110),
              child: ProjectCard(project: project, compact: true)
                  .animate(target: isCut ? 1 : 0)
                  .fadeIn(duration: 500.ms)
                  .scaleXY(begin: 0.92, end: 1, curve: Curves.easeOutBack),
            ),
            // Chains + plate, swaying, until slashed.
            IgnorePointer(
                  ignoring: isCut,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => game.dashTo(index),
                      child: _Plate(
                        game: game,
                        index: index,
                        title: project.title,
                      ),
                    ),
                  ),
                )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                  delay: (index * 300).ms,
                )
                .rotate(
                  begin: -0.008,
                  end: 0.008,
                  alignment: Alignment.topCenter,
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                )
                .animate(target: isCut ? 1 : 0)
                .moveY(
                  begin: 0,
                  end: 1100,
                  duration: 1300.ms,
                  curve: Curves.easeInBack,
                )
                .rotate(
                  begin: 0,
                  end: index.isEven ? 0.12 : -0.12,
                  duration: 1300.ms,
                )
                .fadeOut(delay: 900.ms, duration: 400.ms),
          ],
        );
      },
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.game, required this.index, required this.title});
  final NinjaGame game;
  final int index;
  final String title;

  static const _kanji = ['壱', '弐', '参', '四', '五'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: game.armed,
      builder: (context, armed, _) {
        final hot = armed == index;
        final edge = hot ? CustomColors.secondary : const Color(0xff8c96a0);
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var k = 0; k < 2; k++)
                  Image.asset(
                    ImageAssets.chain,
                    height: 110,
                    color: hot ? CustomColors.secondary : null,
                    colorBlendMode: BlendMode.modulate,
                  ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 420,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff59626b),
                    Color(0xff2b3138),
                    Color(0xff4a535c),
                    Color(0xff1f242a),
                  ],
                  stops: [0, 0.4, 0.6, 1],
                ),
                border: Border.all(color: edge, width: hot ? 2.5 : 1.5),
                boxShadow: [
                  BoxShadow(
                    color: (hot ? CustomColors.secondary : Colors.black)
                        .withValues(alpha: hot ? 0.6 : 0.5),
                    blurRadius: hot ? 24 : 12,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  for (final a in const [
                    Alignment(-0.85, -0.9),
                    Alignment(0.85, -0.9),
                    Alignment(-0.85, 0.9),
                    Alignment(0.85, 0.9),
                  ])
                    Align(
                      alignment: a,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0xffd5dce2), Color(0xff4b535b)],
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _kanji[index % _kanji.length],
                          style: TextStyle(
                            fontSize: 110,
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withValues(alpha: 0.35),
                            shadows: [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.15),
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          hot ? 'SLASH NOW!' : 'SEALED',
                          style: TextStyle(
                            color: hot
                                ? CustomColors.secondary
                                : Colors.white.withValues(alpha: 0.45),
                            letterSpacing: 4,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.game});
  final NinjaGame game;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const _Key(keys: '← →', label: 'run'),
            const _Key(keys: 'Space', label: 'jump'),
            const _Key(keys: 'Ctrl / X', label: 'slash'),
            const _Key(keys: 'Click', label: 'a plate to auto-strike'),
            const SoundToggle(),
            IconButton(
              tooltip: 'Re-seal the plates',
              onPressed: game.reset,
              icon: const Icon(Icons.replay_rounded, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.keys, required this.label});
  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
            color: Colors.white.withValues(alpha: 0.06),
          ),
          child: Text(
            keys,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
