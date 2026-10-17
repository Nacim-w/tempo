import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// A tiny animated equalizer. Bars bounce while [playing] is true.
class PlayingBars extends StatefulWidget {
  const PlayingBars({
    super.key,
    required this.playing,
    this.color = AppColors.lime,
    this.barCount = 4,
    this.height = 18,
    this.barWidth = 3,
  });

  final bool playing;
  final Color color;
  final int barCount;
  final double height;
  final double barWidth;

  @override
  State<PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<PlayingBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PlayingBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.playing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (i) {
              final phase = (_controller.value + i / widget.barCount) % 1.0;
              final wave = (phase < 0.5 ? phase : 1 - phase) * 2;
              final factor = widget.playing ? (0.3 + wave * 0.7) : 0.35;
              return Padding(
                padding: EdgeInsets.only(right: i == widget.barCount - 1 ? 0 : 3),
                child: Container(
                  width: widget.barWidth,
                  height: widget.height * factor,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
