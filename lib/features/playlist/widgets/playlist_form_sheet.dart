import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/sample_library.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/playlist.dart';
import '../../../widgets/cover.dart';
import '../../library/cubit/library_cubit.dart';

Future<void> showPlaylistFormSheet(
  BuildContext context, {
  Playlist? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PlaylistFormSheet(existing: existing),
  );
}

class _PlaylistFormSheet extends StatefulWidget {
  const _PlaylistFormSheet({this.existing});

  final Playlist? existing;

  @override
  State<_PlaylistFormSheet> createState() => _PlaylistFormSheetState();
}

class _PlaylistFormSheetState extends State<_PlaylistFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _cover;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _description =
        TextEditingController(text: widget.existing?.description ?? '');
    _cover = widget.existing?.cover ?? sampleAlbums.first.cover;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give your playlist a name.');
      return;
    }
    final cubit = context.read<LibraryCubit>();
    if (widget.existing != null) {
      cubit.updatePlaylist(widget.existing!.copyWith(
        name: name,
        description: _description.text.trim(),
        cover: _cover,
      ));
    } else {
      cubit.createPlaylist(
        name: name,
        description: _description.text.trim(),
        cover: _cover,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 4, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PLAYLIST',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  color: AppColors.textSoft,
                )),
            const SizedBox(height: 8),
            Text(
              widget.existing == null ? 'New collection' : 'Edit playlist',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Playlist name'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(hintText: 'Description (optional)'),
            ),
            const SizedBox(height: 18),
            const Text('COVER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  color: AppColors.textSoft,
                )),
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sampleAlbums.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final cover = sampleAlbums[i].cover;
                  final selected = cover == _cover;
                  return GestureDetector(
                    onTap: () => setState(() => _cover = cover),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? AppColors.lime : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Cover(asset: cover, size: 80, radius: 12),
                    ),
                  );
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.magenta,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
              child: Text(
                  widget.existing == null ? 'Create playlist' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
