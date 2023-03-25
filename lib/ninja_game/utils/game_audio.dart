import 'package:flame_audio/flame_audio.dart';

class GameAudio {
  static const String jump = 'jump.wav';
  static const String sword = 'sword.wav';
  static const String cutTheChain = 'cut_the_chain.mp3';
  static const String ninjaSoundTrack = 'ninja_sound_track.mp3';

  static Future<void> preload() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([jump, sword, cutTheChain,ninjaSoundTrack]);
  }

  static void playJump() {
    FlameAudio.play(jump);
  }

 static void playSword() {
    FlameAudio.play(sword);
  }

 static void playCutTheChain() {
    FlameAudio.play(cutTheChain);
  }

  static Future playNinjaSoundTrack()async {
    await FlameAudio.bgm.play(ninjaSoundTrack);
  }

  static Future stopNinjaSoundTrack()async{
    await FlameAudio.bgm.stop();
  }
  
  static void dispose(){
    FlameAudio.bgm.dispose();
  }
}
