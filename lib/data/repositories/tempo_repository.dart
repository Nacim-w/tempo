import '../models/playlist.dart';

abstract class TempoRepository {
  List<Playlist>? loadPlaylists();
  Future<void> savePlaylists(List<Playlist> playlists);

  List<String>? loadLiked();
  Future<void> saveLiked(List<String> ids);

  String newId();
}
