import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme/app_colors.dart';
import '../data/models/playlist.dart';
import 'cover.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.trackCount,
    required this.onTap,
    this.size = 160,
  });

  final Playlist playlist;
  final int trackCount;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Cover(asset: playlist.cover, size: size, radius: 18),
            const SizedBox(height: 10),
            Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              plural(trackCount, 'track'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
