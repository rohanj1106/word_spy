import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/player_progress_provider.dart';
import '../viewmodel/postcard_viewmodel.dart';

class PostcardRevealScreen extends ConsumerWidget {
  final String chapterId;
  const PostcardRevealScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postcardProvider(chapterId));
    final vm = ref.read(postcardProvider(chapterId).notifier);

    if (state.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final chapter = state.chapter;
    if (chapter == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Chapter not found',
              style: AppTypography.body(color: AppColors.textPrimary)),
        ),
      );
    }

    final revealed = vm.revealedLines;
    final totalPuzzles = chapter.puzzles.length;
    final solvedCount = revealed.where((v) => v).length;
    final chapterComplete = solvedCount == totalPuzzles;
    final nextPuzzleNumber = solvedCount + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0D4A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0D4A), Color(0xFF2C1F6B), Color(0xFF3D2B8F)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── App bar ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm, vertical: AppSizes.xs),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white70, size: 18),
                        onPressed: () => context.go('/chapters'),
                      ),
                      Expanded(
                        child: Text(
                          '${chapter.flag} ${chapter.city} · Postcard',
                          style: AppTypography.subheading(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      children: [
                        // ── Progress strip ───────────────────────
                        _ProgressStrip(
                          solved: solvedCount,
                          total: totalPuzzles,
                          complete: chapterComplete,
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // ── Vintage postcard ─────────────────────
                        _VintagePostcard(
                          chapter: chapter,
                          revealed: revealed,
                          totalPuzzles: totalPuzzles,
                        ),

                        const SizedBox(height: AppSizes.xl),

                        // ── Action button ────────────────────────
                        if (chapterComplete)
                          _ChapterCompleteButton(
                            chapterId: chapterId,
                            ref: ref,
                            context: context,
                          )
                        else
                          _NextPuzzleButton(
                            onTap: () => context.pushReplacement(
                              '/puzzle/$chapterId/$nextPuzzleNumber',
                            ),
                            puzzleNumber: nextPuzzleNumber,
                          ),

                        const SizedBox(height: AppSizes.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress strip ────────────────────────────────────────────────────────────

class _ProgressStrip extends StatelessWidget {
  final int solved;
  final int total;
  final bool complete;

  const _ProgressStrip(
      {required this.solved, required this.total, required this.complete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 16),
          const SizedBox(width: AppSizes.sm),
          Text(
            complete ? 'Chapter Complete!' : '$solved of $total puzzles solved',
            style: AppTypography.caption(color: Colors.white70),
          ),
          const Spacer(),
          // Dot indicators
          Row(
            children: List.generate(total, (i) {
              final done = i < solved;
              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: done ? 10 : 8,
                height: done ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.25),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ── Vintage postcard ──────────────────────────────────────────────────────────

class _VintagePostcard extends StatelessWidget {
  final dynamic chapter;
  final List<bool> revealed;
  final int totalPuzzles;

  const _VintagePostcard({
    required this.chapter,
    required this.revealed,
    required this.totalPuzzles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8EF), // aged paper
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Postcard header strip ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg, vertical: AppSizes.sm),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE0C4),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLg)),
            ),
            child: Row(
              children: [
                Text(chapter.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FROM: ${chapter.city.toUpperCase()}',
                        style: AppTypography.caption(
                                color: AppColors.textSecondary)
                            .copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        chapter.postcard.storyTitle,
                        style: AppTypography.caption(
                                color: AppColors.textPrimary)
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                // Postage stamp decoration
                _PostageStamp(flag: chapter.flag),
              ],
            ),
          ),

          // ── Divider (perforated) ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              children: List.generate(
                40,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i.isEven
                        ? const Color(0xFFD4C5A9)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // ── Story lines ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                chapter.postcard.storyLines.length,
                (i) {
                  final isRevealed = i < revealed.length && revealed[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: isRevealed ? 1.0 : 1.0,
                      child: isRevealed
                          ? Text(
                              chapter.postcard.storyLines[i],
                              style: AppTypography.body(
                                      color: const Color(0xFF2C1A0E))
                                  .copyWith(
                                height: 1.6,
                                fontStyle: i == 0 ||
                                        i ==
                                            chapter.postcard.storyLines.length -
                                                1
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ).animate().fadeIn(
                                duration: 600.ms,
                                delay: Duration(milliseconds: i * 80))
                          : Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4C5A9),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4C5A9),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

// ── Postage stamp ─────────────────────────────────────────────────────────────

class _PostageStamp extends StatelessWidget {
  final String flag;
  const _PostageStamp({required this.flag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _StampBorderPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              const Text(
                'POSTCARD',
                style: TextStyle(
                  fontSize: 5,
                  color: Color(0xFF8B4513),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StampBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4C5A9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const notch = 4.0;
    const count = 8;

    for (int i = 0; i <= count; i++) {
      final x = size.width * i / count;
      canvas.drawCircle(Offset(x, 0), notch / 2, paint..style = PaintingStyle.fill..color = const Color(0xFFEDE0C4));
      canvas.drawCircle(Offset(x, size.height), notch / 2, paint);
    }
    for (int i = 0; i <= count + 2; i++) {
      final y = size.height * i / (count + 2);
      canvas.drawCircle(Offset(0, y), notch / 2, paint);
      canvas.drawCircle(Offset(size.width, y), notch / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _ChapterCompleteButton extends StatelessWidget {
  final String chapterId;
  final WidgetRef ref;
  final BuildContext context;

  const _ChapterCompleteButton({
    required this.chapterId,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          final notifier = ref.read(playerProgressProvider.notifier);
          await notifier.markChapterComplete(chapterId);
          await notifier.addCoins(100);
          if (context.mounted) context.go('/chapters');
        },
        icon: const Icon(Icons.emoji_events, color: Colors.black87),
        label: const Text(
          'Chapter Complete! +100 🪙',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.black87),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          elevation: 8,
          shadowColor: AppColors.accent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut);
  }
}

class _NextPuzzleButton extends StatelessWidget {
  final VoidCallback onTap;
  final int puzzleNumber;

  const _NextPuzzleButton(
      {required this.onTap, required this.puzzleNumber});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: Text(
          'Puzzle $puzzleNumber →',
          style: AppTypography.subheading(color: Colors.white),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }
}
