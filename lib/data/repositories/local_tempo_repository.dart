import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';
import 'tempo_repository.dart';

class LocalTempoRepository implements TempoRepository {
  LocalTempoRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _playlistsKey = 'tempo.playlists';
  static const _likedKey = 'tempo.liked';

  @override
  List<Playlist>? loadPlaylists() {
    final raw = _prefs.getString(_playlistsKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlaylists(List<Playlist> playlists) {
    final raw = jsonEncode(playlists.map((p) => p.toJson()).toList());
    return _prefs.setString(_playlistsKey, raw);
  }

  @override
  List<String>? loadLiked() => _prefs.getStringList(_likedKey);

  @override
  Future<void> saveLiked(List<String> ids) =>
      _prefs.setStringList(_likedKey, ids);

  @override
  String newId() => 'p${DateTime.now().microsecondsSinceEpoch}';
}
