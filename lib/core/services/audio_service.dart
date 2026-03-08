import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _muted = false;

  Future<void> playBgMusic() async {
    try {
      await _bgPlayer.setVolume(0.3);
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
    } catch (_) {}
  }

  Future<void> pauseBgMusic() async {
    try {
      await _bgPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeBgMusic() async {
    if (_muted) return;
    try {
      await _bgPlayer.resume();
    } catch (_) {}
  }

  Future<void> playCoin() async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/coin.mp3'));
    } catch (_) {}
  }

  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      _bgPlayer.setVolume(0);
    } else {
      _bgPlayer.setVolume(0.3);
    }
  }

  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
