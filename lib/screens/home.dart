import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../audio/sound_fx.dart';
import '../effects/blade_background.dart';
import '../effects/css_backdrop.dart';
import '../effects/cursor_blade_trail.dart';
import '../effects/ninja_duel.dart';
import '../effects/shader_primer.dart';
import '../sections/contact.dart';
import '../sections/experience.dart';
import '../sections/overview.dart';
import '../sections/projects.dart';
import '../sections/skills.dart';
import '../sections/welcome.dart';
import '../three_d/shuriken_icon.dart';
import '../utils/custom_colors.dart';
import '../widgets/footer.dart';
import '../widgets/navbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = ScrollController();
  final _pointer = ValueNotifier<Offset?>(null);
  final _progress = ValueNotifier<double>(0);
  final _active = ValueNotifier<int>(0);
  final _showTop = ValueNotifier<bool>(false);

  late final _items = [
    NavItem('Home', GlobalKey(debugLabel: 'home')),
    NavItem('Overview', GlobalKey(debugLabel: 'overview')),
    NavItem('Experience', GlobalKey(debugLabel: 'experience')),
    NavItem('Duel', GlobalKey(debugLabel: 'duel')),
    NavItem('Projects', GlobalKey(debugLabel: 'projects')),
    NavItem('Contact', GlobalKey(debugLabel: 'contact')),
  ];

  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    HardwareKeyboard.instance.addHandler(_unlockAudio);
    // Fetch the (small) effect files once the first frame is up, so they are
    // ready the moment the visitor's first click unlocks audio.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Future.delayed(const Duration(seconds: 2), SoundFx.preload),
    );
  }

  void _onScroll() {
    final position = _controller.position;
    final max = position.maxScrollExtent;
    _progress.value = max <= 0 ? 0 : (position.pixels / max).clamp(0.0, 1.0);
    final vh = position.viewportDimension;
    _showTop.value = position.pixels > vh;

    // The active section is the last one whose top has passed 40% of the view.
    var active = 0;
    for (var i = 0; i < _items.length; i++) {
      final box =
          _items[i].key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= vh * 0.4) active = i;
    }
    _active.value = active;

    // Decode the duel's 80 sprite frames once the visitor heads that way,
    // instead of competing with the first paint for bandwidth and memory.
    if (!_precached && active >= 1) {
      _precached = true;
      NinjaSprites.precache(context);
    }
  }

  void _scrollTo(int i) {
    final ctx = _items[i].key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: 1200.ms,
      curve: Curves.easeInOutCubic,
    );
  }

  /// A key press also counts as the gesture browsers require for audio.
  bool _unlockAudio(KeyEvent event) {
    SoundFx.unlock();
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_unlockAudio);
    _controller.dispose();
    _pointer.dispose();
    _progress.dispose();
    _active.dispose();
    _showTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent on web so the CSS sky and vignette show through.
      backgroundColor: CssBackdrop.supported
          ? Colors.transparent
          : CustomColors.darkBackground,
      body: CursorBladeTrail(
        pointer: _pointer,
        child: Stack(
          children: [
            Positioned.fill(
              child: BladeBackground(
                controller: _controller,
                pointer: _pointer,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    // Each section gets its own layer, so a section that
                    // animates (typewriter, duel, game) repaints only itself.
                    RepaintBoundary(
                      child: Welcome(
                        key: _items[0].key,
                        onSeeWork: () => _scrollTo(4),
                      ),
                    ),
                    RepaintBoundary(child: Overview(key: _items[1].key)),
                    RepaintBoundary(child: Experience(key: _items[2].key)),
                    const RepaintBoundary(child: Skills()),
                    RepaintBoundary(child: NinjaDuel(key: _items[3].key)),
                    RepaintBoundary(child: Projects(key: _items[4].key)),
                    RepaintBoundary(child: Contact(key: _items[5].key)),
                    const RepaintBoundary(child: Footer()),
                  ],
                ),
              ),
            ),
            // Draws upcoming sections invisibly so their GPU shaders are
            // compiled before the visitor scrolls to them (under the navbar).
            const Positioned(top: 0, left: 0, child: ShaderPrimer()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              // The bar sits above the scroll view, so mouse-wheel events over
              // it would otherwise never reach the page.
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent && _controller.hasClients) {
                    _controller.position.pointerScroll(event.scrollDelta.dy);
                  }
                },
                child: Navbar(
                  items: _items,
                  active: _active,
                  progress: _progress,
                  onSelect: _scrollTo,
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: ValueListenableBuilder<bool>(
                valueListenable: _showTop,
                builder: (context, show, _) => AnimatedScale(
                  scale: show ? 1 : 0,
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                  child: _BackToTop(
                    progress: _progress,
                    onTap: () => _controller.animateTo(
                      0,
                      duration: 1600.ms,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A spinning shuriken that throws you back to the top.
class _BackToTop extends StatelessWidget {
  const _BackToTop({required this.progress, required this.onTap});
  final ValueListenable<double> progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back to top',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColors.glass,
              border: Border.all(
                color: CustomColors.primary.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: CustomColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                ),
              ],
            ),
            child: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (context, p, _) => ShurikenIcon(angle: p * 40),
            ),
          ),
        ),
      ),
    );
  }
}
