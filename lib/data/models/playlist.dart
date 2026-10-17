import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.cover,
    required this.trackIds,
  });

  final String id;
  final String name;
  final String description;
  final String cover;
  final List<String> trackIds;

  Playlist copyWith({
    String? name,
    String? description,
    String? cover,
    List<String>? trackIds,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      cover: cover ?? this.cover,
      trackIds: trackIds ?? this.trackIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cover': cover,
        'trackIds': trackIds,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
        trackIds: (json['trackIds'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
      );

  @override
  List<Object?> get props => [id, name, description, cover, trackIds];
}
