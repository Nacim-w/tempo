import 'package:equatable/equatable.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumId,
    required this.albumTitle,
    required this.cover,
    required this.duration,
    required this.accent,
  });

  final String id;
  final String title;
  final String artist;
  final String albumId;
  final String albumTitle;
  final String cover;
  final Duration duration;
  final int accent;

  @override
  List<Object?> get props => [id];
}
