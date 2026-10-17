import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/format.dart';
import '../../core/sample_library.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/album_card.dart';
import '../../widgets/cover.dart';
import '../../widgets/section_header.dart';
import '../album/album_page.dart';
import '../player/cubit/player_cubit.dart';
import '../playlist/playlist_page.dart';
import '../playlist/widgets/playlist_form_sheet.dart';
import 'cubit/library_cubit.dart';
import 'cubit/library_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text('Your Library',
                              style:
                                  Theme.of(context).textTheme.displayLarge),
                        ),
                        IconButton.filled(
                          onPressed: () => showPlaylistFormSheet(context),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.lime,
                            foregroundColor: const Color(0xFF0A0A0A),
                          ),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(
                  child: SectionHeader(eyebrow: 'Collections', title: 'Playlists'),
                ),
                if (state.playlists.isEmpty)
                  const SliverToBoxAdapter(child: _NoPlaylists())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList.builder(
                      itemCount: state.playlists.length,
                      itemBuilder: (context, i) {
                        final p = state.playlists[i];
                        final tracks = state.tracksOf(p);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          leading: Cover(
                            asset: p.cover,
                            size: 56,
                            radius: 14,
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                          ),
                          subtitle: Text(
                            '${plural(p.trackIds.length, 'track')} · '
                            '${p.description.isEmpty ? 'No description' : p.description}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSoft),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              if (tracks.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('This playlist is empty.')),
                                );
                                return;
                              }
                              context
                                  .read<PlayerCubit>()
                                  .playTrack(tracks.first, queue: tracks);
                            },
                            icon: const Icon(Icons.play_circle_fill,
                                size: 34, color: AppColors.lime),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlaylistPage(playlistId: p.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                const SliverToBoxAdapter(
                  child: SectionHeader(eyebrow: 'Saved', title: 'Albums'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 228,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: sampleAlbums.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        final a = sampleAlbums[i];
                        return AlbumCard(
                          album: a,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => AlbumPage(album: a)),
                          ),
                          onPlay: () => context
                              .read<PlayerCubit>()
                              .playTrack(a.tracks.first, queue: a.tracks),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoPlaylists extends StatelessWidget {
  const _NoPlaylists();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.queue_music_rounded,
                color: AppColors.textSoft, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No playlists yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Create one to collect your favourite tracks.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => showPlaylistFormSheet(context),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
