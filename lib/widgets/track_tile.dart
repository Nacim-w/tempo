import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme/app_colors.dart';
import '../data/models/track.dart';
import 'cover.dart';
import 'playing_bars.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
    this.index,
    this.trailing,
  });

  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final int? index;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = Color(track.accent);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: isCurrent
                    ? Center(child: PlayingBars(playing: isPlaying, color: accent))
                    : Text(
                        index != null ? '${index! + 1}'.padLeft(2, '0') : '',
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Cover(
                asset: track.cover,
                size: 46,
                radius: 10,
                accent: track.accent,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Archivo',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: isCurrent ? accent : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artist,
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
              const SizedBox(width: 10),
              if (trailing != null)
                trailing!
              else
                Text(
                  formatDuration(track.duration),
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
