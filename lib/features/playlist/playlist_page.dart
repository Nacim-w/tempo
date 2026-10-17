import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/format.dart';
import '../../core/sample_library.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/track.dart';
import '../../widgets/cover.dart';
import '../../widgets/track_tile.dart';
import '../library/cubit/library_cubit.dart';
import '../library/cubit/library_state.dart';
import '../player/cubit/player_cubit.dart';
import '../player/cubit/player_state.dart';
import 'widgets/playlist_form_sheet.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final playlist = state.byId(playlistId);
        if (playlist == null) {
          return const Scaffold(
            body: Center(
              child: Text('This playlist no longer exists.',
                  style: TextStyle(color: AppColors.textSoft)),
            ),
          );
        }
        final tracks = state.tracksOf(playlist);
        final accent = tracks.isNotEmpty ? Color(tracks.first.accent) : AppColors.lime;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.canvas,
                actions: [
                  PopupMenuButton<String>(
                    color: AppColors.elevated,
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'edit') {
                        showPlaylistFormSheet(context, existing: playlist);
                      } else if (value == 'delete') {
                        _confirmDelete(context, playlist.name);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit playlist')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
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
                              accent.withValues(alpha: 0.7),
                              AppColors.canvas,
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 44),
                            Cover(
                              asset: playlist.cover,
                              size: 180,
                              radius: 22,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                playlist.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              plural(playlist.trackIds.length, 'track'),
                              style: const TextStyle(
                                color: AppColors.textSoft,
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playlist.description.isNotEmpty) ...[
                        Text(playlist.description,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: tracks.isEmpty
                                  ? null
                                  : () => context
                                      .read<PlayerCubit>()
                                      .playTrack(tracks.first, queue: tracks),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: const Color(0xFF0A0A0A),
                                minimumSize: const Size.fromHeight(50),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _showAddTracks(context, playlist.id),
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.line),
                              minimumSize: const Size(0, 50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (tracks.isEmpty)
                SliverToBoxAdapter(child: _empty(context, playlist.id))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 60),
                  sliver: SliverToBoxAdapter(
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: tracks.length,
                      onReorder: (oldIndex, newIndex) => context
                          .read<LibraryCubit>()
                          .reorderTracks(playlist.id, oldIndex, newIndex),
                      itemBuilder: (context, i) {
                        final t = tracks[i];
                        return _TrackRow(
                          key: ValueKey(t.id),
                          track: t,
                          index: i,
                          queue: tracks,
                          onRemove: () => context
                              .read<LibraryCubit>()
                              .removeTrack(playlist.id, t.id),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context, String playlistId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            const Icon(Icons.music_note_rounded,
                color: AppColors.textSoft, size: 32),
            const SizedBox(height: 12),
            Text('This playlist is empty',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Add a few tracks to get it going.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _showAddTracks(context, playlistId),
              icon: const Icon(Icons.add),
              label: const Text('Add tracks'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final cubit = context.read<LibraryCubit>();
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const Text('Delete playlist?'),
        content: Text('"$name" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      cubit.deletePlaylist(playlistId);
      navigator.maybePop();
    }
  }

  void _showAddTracks(BuildContext context, String playlistId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            final playlist = state.byId(playlistId);
            final selected = playlist?.trackIds.toSet() ?? {};
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Text('Add tracks',
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
                      itemCount: allTracks.length,
                      itemBuilder: (context, i) {
                        final t = allTracks[i];
                        final isSelected = selected.contains(t.id);
                        return ListTile(
                          leading: Cover(
                              asset: t.cover,
                              size: 44,
                              radius: 10,
                              accent: t.accent),
                          title: Text(t.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                          subtitle: Text(t.albumTitle,
                              style: const TextStyle(
                                  color: AppColors.textSoft)),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: isSelected
                                ? AppColors.lime
                                : AppColors.textSoft,
                          ),
                          onTap: () {
                            if (isSelected) {
                              context
                                  .read<LibraryCubit>()
                                  .removeTrack(playlistId, t.id);
                            } else {
                              context
                                  .read<LibraryCubit>()
                                  .addTrack(playlistId, t.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    super.key,
    required this.track,
    required this.index,
    required this.queue,
    required this.onRemove,
  });

  final Track track;
  final int index;
  final List<Track> queue;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: BlocBuilder<PlayerCubit, PlayerState>(
        buildWhen: (p, n) =>
            p.current?.id != n.current?.id || p.isPlaying != n.isPlaying,
        builder: (context, state) {
          return TrackTile(
            track: track,
            index: index,
            isCurrent: state.current?.id == track.id,
            isPlaying: state.isPlaying,
            onTap: () =>
                context.read<PlayerCubit>().playTrack(track, queue: queue),
            trailing: IconButton(
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close,
                  size: 18, color: AppColors.textSoft),
            ),
          );
        },
      ),
    );
  }
}
