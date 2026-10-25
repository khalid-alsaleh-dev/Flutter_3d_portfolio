import 'package:flutter/material.dart';

import '../utils/custom_colors.dart';
import 'sound_fx.dart';

/// Speaker button. Shows "muted" until audio is both enabled and unlocked by
/// the browser, so the first press always means "turn sound on".
class SoundToggle extends StatefulWidget {
  const SoundToggle({super.key, this.color = Colors.white70});

  final Color color;

  @override
  State<SoundToggle> createState() => _SoundToggleState();
}

class _SoundToggleState extends State<SoundToggle> {
  // Captured on pointer down, before the page-wide listener unlocks audio for
  // this same press (inner listeners receive the event first).
  bool _audibleAtDown = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _audibleAtDown = SoundFx.audible,
      child: ListenableBuilder(
        listenable: Listenable.merge([SoundFx.enabled, SoundFx.unlocked]),
        builder: (context, _) {
          final on = SoundFx.audible;
          return IconButton(
            tooltip: on ? 'Mute' : 'Sound on',
            onPressed: () => SoundFx.toggle(wasAudible: _audibleAtDown),
            icon: Icon(
              on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: on ? CustomColors.primary : widget.color,
            ),
          );
        },
      ),
    );
  }
}
