import 'package:equatable/equatable.dart';

import 'track.dart';

class Album extends Equatable {
  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.cover,
    required this.accent,
    required this.tracks,
  });

  final String id;
  final String title;
  final String artist;
  final int year;
  final String cover;
  final int accent;
  final List<Track> tracks;

  @override
  List<Object?> get props => [id];
}
