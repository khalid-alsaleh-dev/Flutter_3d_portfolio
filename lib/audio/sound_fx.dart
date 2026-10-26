import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'sfx_backend_stub.dart'
    if (dart.library.js_interop) 'sfx_backend_web.dart'
    as web_audio;

/// Site-wide sound effects and the dojo soundtrack.
///
/// Sound is on by default, but browsers refuse to play audio until the visitor
/// has clicked, tapped or pressed a key (scrolling does not count). Until
/// [unlock] is called from such a gesture, every request is silently dropped.
/// Downloading needs no gesture, so [preload] fetches everything up front.
///
/// On the web, effects play through the Web Audio API (decoded once, started
/// in a few milliseconds, freely overlapping). Elsewhere they use pooled
/// players. The effect files are trimmed to start on their first sound: any
/// leading silence is heard as lag between an action and its sound.
class SoundFx {
  static const jump = 'jump.wav';
  static const sword = 'sword.wav';
  static const cut = 'cut_the_chain.wav';
  static const _soundtrack = 'ninja_sound_track.mp3';

  /// The visitor's preference.
  static final enabled = ValueNotifier<bool>(true);

  /// Whether the browser will actually let us play anything yet.
  static final unlocked = ValueNotifier<bool>(false);

  /// True when sounds will actually be heard.
  static bool get audible => enabled.value && unlocked.value;

  static final Map<String, AudioPool> _pools = {};
  static Future<void>? _preloading;
  static bool _musicWanted = false;
  static bool _musicPlaying = false;

  /// Downloads and prepares every effect in parallel, so the first sound after
  /// unlocking plays immediately. Safe to call more than once.
  static Future<void> preload() => _preloading ??= Future.wait([
    _load(jump, 2),
    _load(sword, 4),
    _load(cut, 2),
  ]);

  static Future<void> _load(String file, int maxPlayers) async {
    try {
      if (web_audio.supported) {
        await web_audio.load(file);
      } else {
        _pools[file] = await FlameAudio.createPool(
          file,
          maxPlayers: maxPlayers,
          minPlayers: 1,
        );
      }
    } catch (e) {
      debugPrint('Sound "$file" unavailable: $e');
    }
  }

  /// Call from inside a user gesture handler.
  static void unlock() {
    // Every gesture retries resuming the audio context, in case an earlier
    // attempt happened outside one.
    web_audio.unlock();
    if (unlocked.value) return;
    unlocked.value = true;
    preload();
    _syncMusic();
  }

  /// Turns sound on or off. [wasAudible] is what the visitor saw when they
  /// pressed the button: the same press may also have just unlocked audio.
  static void toggle({required bool wasAudible}) {
    unlock();
    enabled.value = !wasAudible;
    _syncMusic();
  }

  static void play(String file, {double volume = 0.8}) {
    if (!audible) return;
    if (web_audio.supported) {
      web_audio.play(file, volume);
      return;
    }
    _pools[file]?.start(volume: volume).catchError((Object e) {
      debugPrint('Sound "$file" failed: $e');
      return () async {};
    });
  }

  /// The soundtrack plays while the dojo is on screen and sound is on.
  static void wantMusic(bool wanted) {
    _musicWanted = wanted;
    _syncMusic();
  }

  static Future<void> _syncMusic() async {
    final shouldPlay = _musicWanted && audible;
    if (shouldPlay == _musicPlaying) return;
    _musicPlaying = shouldPlay;
    try {
      if (shouldPlay) {
        await FlameAudio.bgm.play(_soundtrack, volume: 0.3);
      } else {
        await FlameAudio.bgm.stop();
      }
    } catch (e) {
      debugPrint('Soundtrack unavailable: $e');
    }
  }
}
