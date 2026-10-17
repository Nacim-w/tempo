import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/track.dart';
import '../../../data/repositories/tempo_repository.dart';
import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._repository)
      : super(PlayerState(liked: (_repository.loadLiked() ?? const []).toSet()));

  final TempoRepository _repository;
  final _random = Random();
  Timer? _timer;

  static const _tick = Duration(milliseconds: 250);

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void playTrack(Track track, {List<Track>? queue}) {
    final list = queue == null || queue.isEmpty ? [track] : [...queue];
    var index = list.indexWhere((t) => t.id == track.id);
    if (index < 0) {
      list.insert(0, track);
      index = 0;
    }
    emit(state.copyWith(
      queue: list,
      index: index,
      position: Duration.zero,
      isPlaying: true,
    ));
    _startTimer();
  }

  void togglePlayPause() {
    if (!state.hasTrack) return;
    if (state.isPlaying) {
      _timer?.cancel();
      emit(state.copyWith(isPlaying: false));
    } else {
      emit(state.copyWith(isPlaying: true));
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  void _onTick() {
    final track = state.current;
    if (track == null || !state.isPlaying) return;
    final next = state.position + _tick;
    if (next >= track.duration) {
      _advance(completed: true);
    } else {
      emit(state.copyWith(position: next));
    }
  }

  void _advance({bool completed = false}) {
    if (state.repeat == RepeatMode.one && completed) {
      emit(state.copyWith(position: Duration.zero, isPlaying: true));
      return;
    }
    var next = state.index + 1;
    if (state.shuffle && state.queue.length > 1) {
      next = _randomIndexExcluding(state.index);
    }
    if (next >= state.queue.length) {
      if (state.repeat == RepeatMode.all) {
        next = 0;
      } else {
        _timer?.cancel();
        emit(state.copyWith(
          position: state.current?.duration ?? Duration.zero,
          isPlaying: false,
        ));
        return;
      }
    }
    emit(state.copyWith(index: next, position: Duration.zero, isPlaying: true));
    _startTimer();
  }

  int _randomIndexExcluding(int exclude) {
    if (state.queue.length <= 1) return 0;
    var candidate = exclude;
    while (candidate == exclude) {
      candidate = _random.nextInt(state.queue.length);
    }
    return candidate;
  }

  void next() => _advance();

  void previous() {
    if (state.position.inSeconds > 3) {
      emit(state.copyWith(position: Duration.zero));
      return;
    }
    var prev = state.index - 1;
    if (prev < 0) {
      prev = state.repeat == RepeatMode.all ? state.queue.length - 1 : 0;
    }
    emit(state.copyWith(index: prev, position: Duration.zero, isPlaying: true));
    _startTimer();
  }

  void seek(Duration position) {
    final track = state.current;
    if (track == null) return;
    final clamped = position < Duration.zero
        ? Duration.zero
        : (position > track.duration ? track.duration : position);
    emit(state.copyWith(position: clamped));
  }

  void toggleShuffle() => emit(state.copyWith(shuffle: !state.shuffle));

  void cycleRepeat() {
    final next = switch (state.repeat) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeat: next));
  }

  Future<void> toggleLike(String id) async {
    final liked = Set<String>.from(state.liked);
    if (!liked.add(id)) liked.remove(id);
    emit(state.copyWith(liked: liked));
    await _repository.saveLiked(liked.toList());
  }

  /// Replaces the queue (used after a playlist edit) keeping the current
  /// track playing if it still exists.
  void syncQueue(List<Track> tracks) {
    if (tracks.isEmpty) return;
    final currentId = state.current?.id;
    final list = [...tracks];
    var index = currentId == null ? 0 : list.indexWhere((t) => t.id == currentId);
    if (index < 0) index = 0;
    emit(state.copyWith(queue: list, index: index));
  }
}
