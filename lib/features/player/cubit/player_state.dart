import 'package:equatable/equatable.dart';

import '../../../data/models/track.dart';

enum RepeatMode { off, all, one }

class PlayerState extends Equatable {
  const PlayerState({
    this.queue = const [],
    this.index = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeat = RepeatMode.off,
    this.liked = const {},
  });

  final List<Track> queue;
  final int index;
  final bool isPlaying;
  final Duration position;
  final bool shuffle;
  final RepeatMode repeat;
  final Set<String> liked;

  bool get hasTrack => queue.isNotEmpty;

  Track? get current => hasTrack ? queue[index] : null;

  double get progress {
    final track = current;
    if (track == null || track.duration.inMilliseconds == 0) return 0;
    return (position.inMilliseconds / track.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  bool isLiked(String id) => liked.contains(id);

  PlayerState copyWith({
    List<Track>? queue,
    int? index,
    bool? isPlaying,
    Duration? position,
    bool? shuffle,
    RepeatMode? repeat,
    Set<String>? liked,
  }) {
    return PlayerState(
      queue: queue ?? this.queue,
      index: index ?? this.index,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
      liked: liked ?? this.liked,
    );
  }

  @override
  List<Object?> get props =>
      [queue, index, isPlaying, position, shuffle, repeat, liked];
}
