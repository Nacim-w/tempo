import 'package:equatable/equatable.dart';

import '../../../core/sample_library.dart';
import '../../../data/models/album.dart';
import '../../../data/models/playlist.dart';
import '../../../data/models/track.dart';

class LibraryState extends Equatable {
  const LibraryState({required this.playlists, this.query = ''});

  final List<Playlist> playlists;
  final String query;

  List<Track> tracksOf(Playlist playlist) =>
      playlist.trackIds.map(trackById).toList();

  Playlist? byId(String id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool get isSearching => query.trim().isNotEmpty;

  List<Album> get albumResults {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return sampleAlbums
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.artist.toLowerCase().contains(q))
        .toList();
  }

  List<Track> get trackResults {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return allTracks
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.artist.toLowerCase().contains(q) ||
            t.albumTitle.toLowerCase().contains(q))
        .toList();
  }

  List<Playlist> get playlistResults {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return playlists
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  LibraryState copyWith({List<Playlist>? playlists, String? query}) {
    return LibraryState(
      playlists: playlists ?? this.playlists,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [playlists, query];
}
