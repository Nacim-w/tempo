import '../data/models/album.dart';
import '../data/models/playlist.dart';
import '../data/models/track.dart';

const String artPath = 'assets/images';

Album _album({
  required String id,
  required String title,
  required String artist,
  required int year,
  required String cover,
  required int accent,
  required List<(String, int)> tracks,
}) {
  return Album(
    id: id,
    title: title,
    artist: artist,
    year: year,
    cover: '$artPath/$cover',
    accent: accent,
    tracks: [
      for (var i = 0; i < tracks.length; i++)
        Track(
          id: '$id-${i + 1}',
          title: tracks[i].$1,
          artist: artist,
          albumId: id,
          albumTitle: title,
          cover: '$artPath/$cover',
          duration: Duration(seconds: tracks[i].$2),
          accent: accent,
        ),
    ],
  );
}

final List<Album> sampleAlbums = [
  _album(
    id: 'midnight',
    title: 'Midnight Signal',
    artist: 'Nova Kane',
    year: 2025,
    cover: 'cover-neon.jpg',
    accent: 0xFFB6FF3C,
    tracks: [
      ('Neon Rain', 214),
      ('Static Bloom', 188),
      ('Midnight Signal', 246),
      ('Afterglow', 205),
    ],
  ),
  _album(
    id: 'analog',
    title: 'Analog Heart',
    artist: 'The Wandering',
    year: 2024,
    cover: 'cover-vinyl.jpg',
    accent: 0xFFFF7A59,
    tracks: [
      ('Vinyl Dreams', 232),
      ('Slow Rewind', 197),
      ('Analog Heart', 268),
    ],
  ),
  _album(
    id: 'neonhall',
    title: 'Live at Neon Hall',
    artist: 'Various Artists',
    year: 2025,
    cover: 'cover-concert.jpg',
    accent: 0xFFFF2E93,
    tracks: [
      ('Overture', 156),
      ('Crowd Noise', 221),
      ('Encore', 289),
    ],
  ),
  _album(
    id: 'prism',
    title: 'Prism',
    artist: 'Lumen',
    year: 2023,
    cover: 'cover-gradient.jpg',
    accent: 0xFF7C5CFF,
    tracks: [
      ('Refraction', 203),
      ('Spectrum', 176),
      ('Prism', 254),
      ('White Light', 198),
    ],
  ),
  _album(
    id: 'slowmotion',
    title: 'Slow Motion',
    artist: 'Adel Rivers',
    year: 2025,
    cover: 'cover-portrait.jpg',
    accent: 0xFF46D9C7,
    tracks: [
      ('Still Frame', 227),
      ('Slow Motion', 241),
      ('Long Exposure', 199),
    ],
  ),
  _album(
    id: 'afterhours',
    title: 'After Hours',
    artist: 'City Lights',
    year: 2024,
    cover: 'cover-citynight.jpg',
    accent: 0xFFFFD166,
    tracks: [
      ('Last Train', 212),
      ('Streetlamps', 184),
      ('After Hours', 233),
      ('Dawn Patrol', 207),
    ],
  ),
  _album(
    id: 'tidal',
    title: 'Tidal',
    artist: 'Ocean Bloom',
    year: 2023,
    cover: 'cover-ocean.jpg',
    accent: 0xFF4FA8FF,
    tracks: [
      ('Undertow', 244),
      ('Salt & Foam', 195),
      ('Tidal', 261),
    ],
  ),
  _album(
    id: 'evergreen',
    title: 'Evergreen',
    artist: 'Forest & Field',
    year: 2025,
    cover: 'cover-forest.jpg',
    accent: 0xFF7ADF9B,
    tracks: [
      ('Moss', 218),
      ('Canopy', 189),
      ('Evergreen', 236),
    ],
  ),
  _album(
    id: 'dunes',
    title: 'Dunes',
    artist: 'Sahara Sound',
    year: 2024,
    cover: 'cover-desert.jpg',
    accent: 0xFFE8A24C,
    tracks: [
      ('Sandstorm', 205),
      ('Mirage', 231),
      ('Dunes', 267),
    ],
  ),
  _album(
    id: 'smoke',
    title: 'Smoke & Mirrors',
    artist: 'Vela',
    year: 2025,
    cover: 'cover-smoke.jpg',
    accent: 0xFFC86BFF,
    tracks: [
      ('Haze', 196),
      ('Illusion', 224),
      ('Smoke & Mirrors', 248),
      ('Vanishing Act', 211),
    ],
  ),
];

List<Track> get allTracks =>
    [for (final a in sampleAlbums) ...a.tracks];

Track trackById(String id) =>
    allTracks.firstWhere((t) => t.id == id, orElse: () => allTracks.first);

Album albumById(String id) =>
    sampleAlbums.firstWhere((a) => a.id == id, orElse: () => sampleAlbums.first);

List<Playlist> get initialPlaylists => [
      Playlist(
        id: 'p-late',
        name: 'Late Night Drive',
        description: 'Neon-lit synths for empty highways.',
        cover: '$artPath/cover-neon.jpg',
        trackIds: ['midnight-1', 'afterhours-1', 'smoke-1', 'midnight-3', 'prism-2'],
      ),
      Playlist(
        id: 'p-focus',
        name: 'Deep Focus',
        description: 'Instrumental textures to disappear into.',
        cover: '$artPath/cover-gradient.jpg',
        trackIds: ['prism-1', 'evergreen-1', 'tidal-1', 'prism-3'],
      ),
      Playlist(
        id: 'p-sunset',
        name: 'Golden Hour',
        description: 'Warm, unhurried and a little nostalgic.',
        cover: '$artPath/cover-desert.jpg',
        trackIds: ['dunes-1', 'slowmotion-1', 'analog-1', 'dunes-2'],
      ),
    ];
