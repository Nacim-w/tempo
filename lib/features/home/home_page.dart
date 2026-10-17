import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/sample_library.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/album.dart';
import '../../widgets/album_card.dart';
import '../../widgets/cover.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';
import '../album/album_page.dart';
import '../library/cubit/library_cubit.dart';
import '../library/cubit/library_state.dart';
import '../player/cubit/player_cubit.dart';
import '../player/cubit/player_state.dart';
import '../playlist/playlist_page.dart';
import '../playlist/widgets/playlist_form_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = sampleAlbums.first;
    final recent = allTracks.take(5).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Greeting()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _JumpBackIn(album: featured),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: const SectionHeader(
                eyebrow: 'Made for you',
                title: 'Albums to sink into',
              ),
            ),
            SliverToBoxAdapter(child: _albumRow(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: SectionHeader(
                eyebrow: 'Your library',
                title: 'Playlists',
                trailing: TextButton.icon(
                  onPressed: () => showPlaylistFormSheet(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _playlistRow(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            const SliverToBoxAdapter(
              child: SectionHeader(
                eyebrow: 'Fresh',
                title: 'Recently played',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 140),
              sliver: SliverList.builder(
                itemCount: recent.length,
                itemBuilder: (context, i) {
                  final t = recent[i];
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
                            .playTrack(t, queue: recent),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _albumRow(BuildContext context) {
    return SizedBox(
      height: 228,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sampleAlbums.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final album = sampleAlbums[i];
          return AlbumCard(
            album: album,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AlbumPage(album: album)),
            ),
            onPlay: () => context
                .read<PlayerCubit>()
                .playTrack(album.tracks.first, queue: album.tracks),
          );
        },
      ),
    );
  }

  Widget _playlistRow(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.playlists.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _NewPlaylistCard(
                  onTap: () => showPlaylistFormSheet(context),
                );
              }
              final p = state.playlists[i - 1];
              return PlaylistCard(
                playlist: p,
                trackCount: p.trackIds.length,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaylistPage(playlistId: p.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GOOD EVENING'.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: AppColors.textSoft,
              )),
          const SizedBox(height: 6),
          Text('Your soundtrack',
              style: Theme.of(context).textTheme.displayLarge),
        ],
      ),
    );
  }
}

class _JumpBackIn extends StatelessWidget {
  const _JumpBackIn({required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    final accent = Color(album.accent);
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final track = state.current ?? album.tracks.first;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AlbumPage(album: album)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withValues(alpha: 0.9), AppColors.surface],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Cover(
                  asset: track.cover,
                  size: 72,
                  radius: 16,
                  accent: track.accent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('JUMP BACK IN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                            color: Colors.white70,
                          )),
                      const SizedBox(height: 6),
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final cubit = context.read<PlayerCubit>();
                    if (state.current?.id == track.id) {
                      cubit.togglePlayPause();
                    } else {
                      cubit.playTrack(track, queue: album.tracks);
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.canvas,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state.isPlaying && state.current?.id == track.id
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: accent,
                      size: 30,
                    ),
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

class _NewPlaylistCard extends StatelessWidget {
  const _NewPlaylistCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
                color: AppColors.surface,
              ),
              child: const Icon(Icons.add_rounded,
                  size: 40, color: AppColors.textSoft),
            ),
            const SizedBox(height: 10),
            Text('New playlist',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
