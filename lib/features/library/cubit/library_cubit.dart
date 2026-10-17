import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/sample_library.dart';
import '../../../data/models/playlist.dart';
import '../../../data/repositories/tempo_repository.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repository)
      : super(LibraryState(
          playlists: _repository.loadPlaylists() ?? initialPlaylists,
        ));

  final TempoRepository _repository;

  void _commit(List<Playlist> playlists) {
    emit(state.copyWith(playlists: playlists));
    _repository.savePlaylists(playlists);
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void clearQuery() => emit(state.copyWith(query: ''));

  Playlist createPlaylist({
    required String name,
    String description = '',
    String? cover,
  }) {
    final playlist = Playlist(
      id: _repository.newId(),
      name: name,
      description: description,
      cover: cover ?? '$artPath/cover-gradient.jpg',
      trackIds: const [],
    );
    _commit([playlist, ...state.playlists]);
    return playlist;
  }

  void updatePlaylist(Playlist playlist) {
    _commit([
      for (final p in state.playlists) if (p.id == playlist.id) playlist else p,
    ]);
  }

  void deletePlaylist(String id) {
    _commit(state.playlists.where((p) => p.id != id).toList());
  }

  void addTrack(String playlistId, String trackId) {
    final p = state.byId(playlistId);
    if (p == null || p.trackIds.contains(trackId)) return;
    updatePlaylist(p.copyWith(trackIds: [...p.trackIds, trackId]));
  }

  void removeTrack(String playlistId, String trackId) {
    final p = state.byId(playlistId);
    if (p == null) return;
    updatePlaylist(
        p.copyWith(trackIds: p.trackIds.where((t) => t != trackId).toList()));
  }

  void reorderTracks(String playlistId, int oldIndex, int newIndex) {
    final p = state.byId(playlistId);
    if (p == null) return;
    final ids = [...p.trackIds];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    updatePlaylist(p.copyWith(trackIds: ids));
  }
}
