import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/track.dart';
import '../../widgets/cover.dart';
import 'cubit/player_cubit.dart';
import 'cubit/player_state.dart';

class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key});

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  double? _dragValue;

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (p, n) => p.isPlaying != n.isPlaying,
      listener: (context, state) {
        if (state.isPlaying) {
          _spin.repeat();
        } else {
          _spin.stop();
        }
      },
      builder: (context, state) {
        final track = state.current;
        if (track == null) {
          return const Scaffold(
            body: Center(
              child: Text('Nothing playing',
                  style: TextStyle(color: AppColors.textSoft)),
            ),
          );
        }
        if (state.isPlaying && !_spin.isAnimating) _spin.repeat();
        final accent = Color(track.accent);
        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: Stack(
            children: [
              Positioned.fill(child: _Backdrop(track: track, accent: accent)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _topBar(context, track, state, accent),
                      const Spacer(flex: 2),
                      _artwork(track, accent),
                      const Spacer(flex: 3),
                      _titleBlock(track, accent),
                      const SizedBox(height: 24),
                      _progress(state, track),
                      const SizedBox(height: 12),
                      _controls(context, state, accent),
                      const SizedBox(height: 18),
                      _queueButton(context),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(
    BuildContext context,
    Track track,
    PlayerState state,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Column(
              children: [
                Text('NOW PLAYING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                      color: AppColors.textSoft,
                    )),
              ],
            ),
          ),
          BlocBuilder<PlayerCubit, PlayerState>(
            buildWhen: (p, n) => p.isLiked(track.id) != n.isLiked(track.id),
            builder: (context, s) {
              final liked = s.isLiked(track.id);
              return _circleButton(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? accent : AppColors.text,
                onTap: () => context.read<PlayerCubit>().toggleLike(track.id),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _artwork(Track track, Color accent) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: _Disc(
        key: ValueKey(track.id),
        track: track,
        accent: accent,
        spin: _spin,
      ),
    );
  }

  Widget _titleBlock(Track track, Color accent) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(track.id),
        children: [
          Text(
            track.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${track.artist} · ${track.albumTitle}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: accent.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(PlayerState state, Track track) {
    final value = _dragValue ?? state.progress;
    final position =
        Duration(milliseconds: (value * track.duration.inMilliseconds).round());
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(track.accent),
            thumbColor: Color(track.accent),
          ),
          child: Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: (v) => setState(() => _dragValue = v),
            onChangeEnd: (v) {
              context.read<PlayerCubit>().seek(Duration(
                    milliseconds:
                        (v * track.duration.inMilliseconds).round(),
                  ));
              setState(() => _dragValue = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(position), style: _timeStyle),
              Text(formatDuration(track.duration), style: _timeStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _controls(BuildContext context, PlayerState state, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => context.read<PlayerCubit>().toggleShuffle(),
          icon: Icon(Icons.shuffle_rounded,
              color: state.shuffle ? accent : AppColors.textSoft),
        ),
        IconButton(
          onPressed: () => context.read<PlayerCubit>().previous(),
          icon: const Icon(Icons.skip_previous_rounded,
              size: 40, color: AppColors.text),
        ),
        _playButton(state, accent),
        IconButton(
          onPressed: () => context.read<PlayerCubit>().next(),
          icon: const Icon(Icons.skip_next_rounded,
              size: 40, color: AppColors.text),
        ),
        IconButton(
          onPressed: () => context.read<PlayerCubit>().cycleRepeat(),
          icon: Icon(
            state.repeat == RepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: state.repeat == RepeatMode.off ? AppColors.textSoft : accent,
          ),
        ),
      ],
    );
  }

  Widget _playButton(PlayerState state, Color accent) {
    return GestureDetector(
      onTap: () => context.read<PlayerCubit>().togglePlayPause(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(state.isPlaying),
            size: 38,
            color: const Color(0xFF0A0A0A),
          ),
        ),
      ),
    );
  }

  Widget _queueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQueue(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.line),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music_rounded, size: 18, color: AppColors.text),
            SizedBox(width: 8),
            Text(
              'Up next',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Text('Up next',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        )),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.queue.length,
                      itemBuilder: (context, i) {
                        final t = state.queue[i];
                        final current = i == state.index;
                        return ListTile(
                          leading: Cover(
                            asset: t.cover,
                            size: 44,
                            radius: 10,
                            accent: t.accent,
                          ),
                          title: Text(
                            t.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: current
                                  ? Color(t.accent)
                                  : AppColors.text,
                            ),
                          ),
                          subtitle: Text(t.artist,
                              style: const TextStyle(
                                  color: AppColors.textSoft)),
                          trailing: current
                              ? const Icon(Icons.equalizer_rounded,
                                  color: AppColors.lime)
                              : null,
                          onTap: () {
                            context
                                .read<PlayerCubit>()
                                .playTrack(t, queue: state.queue);
                            Navigator.of(sheetContext).pop();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }

  static const _timeStyle = TextStyle(
    color: AppColors.textSoft,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

class _Disc extends StatelessWidget {
  const _Disc({
    super.key,
    required this.track,
    required this.accent,
    required this.spin,
  });

  final Track track;
  final Color accent;
  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.72;
    return RotationTransition(
      turns: spin,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF1A1A22), Color(0xFF0A0A0E)],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 60,
              spreadRadius: 4,
            ),
            const BoxShadow(
              color: Colors.black,
              blurRadius: 30,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.62,
            height: size * 0.62,
            child: ClipOval(
              child: Image.asset(
                track.cover,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(color: accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.track, required this.accent});

  final Track track;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Opacity(
            opacity: 0.45,
            child: Image.asset(
              track.cover,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(color: accent),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.canvas.withValues(alpha: 0.55),
                AppColors.canvas.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
