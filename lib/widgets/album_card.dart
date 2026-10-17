import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/album.dart';
import 'cover.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    required this.onPlay,
    this.size = 160,
  });

  final Album album;
  final VoidCallback onTap;
  final VoidCallback onPlay;
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
            Stack(
              children: [
                Cover(
                  asset: album.cover,
                  size: size,
                  radius: 18,
                  accent: album.accent,
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Color(album.accent),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(album.accent).withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Color(0xFF0A0A0A), size: 24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              album.title,
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
              album.artist,
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
