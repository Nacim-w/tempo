import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/album.dart';
import '../../widgets/cover.dart';
import '../../widgets/track_tile.dart';
import '../player/cubit/player_cubit.dart';
import '../player/cubit/player_state.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key, required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    final accent = Color(album.accent);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.canvas,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accent.withValues(alpha: 0.85),
                          AppColors.canvas,
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Cover(
                            asset: album.cover,
                            size: 190,
                            radius: 22,
                            accent: album.accent,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          album.title,
                          textAlign: TextAlign.center,
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
                          '${album.artist} · ${album.year}',
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  _PlayAllButton(album: album, accent: accent),
                  const Spacer(),
                  Text(
                    plural(album.tracks.length, 'track'),
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 60),
            sliver: SliverList.builder(
              itemCount: album.tracks.length,
              itemBuilder: (context, i) {
                final t = album.tracks[i];
                return BlocBuilder<PlayerCubit, PlayerState>(
                  buildWhen: (p, n) =>
                      p.current?.id != n.current?.id ||
                      p.isPlaying != n.isPlaying,
                  builder: (context, state) {
                    return TrackTile(
                      track: t,
                      index: i,
                      isCurrent: state.current?.id == t.id,
                      isPlaying: state.isPlaying,
                      onTap: () => context
                          .read<PlayerCubit>()
                          .playTrack(t, queue: album.tracks),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayAllButton extends StatelessWidget {
  const _PlayAllButton({required this.album, required this.accent});

  final Album album;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (p, n) =>
          p.isPlaying != n.isPlaying ||
          p.current?.albumId != n.current?.albumId,
      builder: (context, state) {
        final isThisAlbum = state.current?.albumId == album.id;
        return GestureDetector(
          onTap: () {
            final cubit = context.read<PlayerCubit>();
            if (isThisAlbum) {
              cubit.togglePlayPause();
            } else {
              cubit.playTrack(album.tracks.first, queue: album.tracks);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isThisAlbum && state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: const Color(0xFF0A0A0A),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  isThisAlbum && state.isPlaying ? 'Pause' : 'Play',
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
