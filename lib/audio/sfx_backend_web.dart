import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;

/// Web Audio playback for short effects.
///
/// Each sound is decoded into memory once and every play is a fresh
/// AudioBufferSourceNode, which starts within a few milliseconds and can
/// overlap freely. HTML `<audio>` elements, which audio plugins use on the
/// web, add noticeable latency to every play.
const bool supported = true;

web.AudioContext? _context;
final Map<String, web.AudioBuffer> _buffers = {};

web.AudioContext get _ctx => _context ??= web.AudioContext();

Future<void> load(String file) async {
  if (_buffers.containsKey(file)) return;
  final data = await rootBundle.load('assets/audio/$file');
  // decodeAudioData takes ownership of (detaches) the buffer, so pass a copy.
  final bytes = Uint8List.fromList(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  _buffers[file] = await _ctx.decodeAudioData(bytes.buffer.toJS).toDart;
}

/// Must run inside a user-gesture handler: browsers create audio contexts
/// suspended and only let a gesture resume them.
void unlock() {
  if (_ctx.state != 'running') _ctx.resume();
}

void play(String file, double volume) {
  final buffer = _buffers[file];
  final ctx = _context;
  if (buffer == null || ctx == null) return;
  if (ctx.state != 'running') ctx.resume();
  final gain = ctx.createGain()..gain.value = volume;
  final source = ctx.createBufferSource()..buffer = buffer;
  source.connect(gain);
  gain.connect(ctx.destination);
  source.start();
}
