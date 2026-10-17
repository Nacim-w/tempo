import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/sample_library.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/album_card.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';
import '../album/album_page.dart';
import '../library/cubit/library_cubit.dart';
import '../library/cubit/library_state.dart';
import '../player/cubit/player_cubit.dart';
import '../player/cubit/player_state.dart';
import '../playlist/playlist_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Text('Search',
                        style: Theme.of(context).textTheme.displayLarge),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _controller,
                      onChanged: context.read<LibraryCubit>().setQuery,
                      decoration: InputDecoration(
                        hintText: 'Songs, artists, albums, playlists',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSoft),
                        suffixIcon: state.isSearching
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: AppColors.textSoft),
                                onPressed: () {
                                  _controller.clear();
                                  context.read<LibraryCubit>().clearQuery();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                if (!state.isSearching)
                  SliverToBoxAdapter(child: _browse(context))
                else
                  ..._results(context, state),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _browse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(eyebrow: 'Browse', title: 'All albums'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: sampleAlbums
                .map((a) => GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => AlbumPage(album: a)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(a.accent).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Color(a.accent).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(a.accent),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _results(BuildContext context, LibraryState state) {
    final albums = state.albumResults;
    final tracks = state.trackResults;
    final playlists = state.playlistResults;

    if (albums.isEmpty && tracks.isEmpty && playlists.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: TempoEmpty(
            icon: Icons.search_off_rounded,
            title: 'No matches',
            message: 'Nothing found for "${state.query.trim()}". Try another '
                'song, artist or album.',
          ),
        ),
      ];
    }

    return [
      if (albums.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Albums'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 228,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: albums.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final a = albums[i];
                return AlbumCard(
                  album: a,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AlbumPage(album: a)),
                  ),
                  onPlay: () => context
                      .read<PlayerCubit>()
                      .playTrack(a.tracks.first, queue: a.tracks),
                );
              },
            ),
          ),
        ),
      ],
      if (playlists.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Playlists'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 228,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final p = playlists[i];
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
          ),
        ),
      ],
      if (tracks.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Songs'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList.builder(
            itemCount: tracks.length,
            itemBuilder: (context, i) {
              final t = tracks[i];
              return BlocBuilder<PlayerCubit, PlayerState>(
                buildWhen: (p, n) =>
                    p.current?.id != n.current?.id ||
                    p.isPlaying != n.isPlaying,
                builder: (context, ps) {
                  return TrackTile(
                    track: t,
                    index: i,
                    isCurrent: ps.current?.id == t.id,
                    isPlaying: ps.isPlaying,
                    onTap: () => context
                        .read<PlayerCubit>()
                        .playTrack(t, queue: tracks),
                  );
                },
              );
            },
          ),
        ),
      ],
    ];
  }
}
