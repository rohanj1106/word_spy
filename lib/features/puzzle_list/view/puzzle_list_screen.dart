import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/puzzle.dart';
import '../../../core/providers/player_progress_provider.dart';
import '../../../core/services/chapter_service.dart';

class PuzzleListScreen extends ConsumerWidget {
  final String chapterId;
  const PuzzleListScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1F),
      body: FutureBuilder<Chapter?>(
        future: ChapterService.getById(chapterId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }
          final chapter = snapshot.data!;
          final solved = progress.puzzlesCompletedInChapter(chapterId);
          final total = chapter.puzzles.length;

          return Stack(
            children: [
              // ── Gradient header bg ──────────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                height: 220,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradientForChapter(chapterId),
                    ),
                  ),
                ),
              ),

              // Decorative circle
              Positioned(
                right: -40, top: -40,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.sm, AppSizes.sm, AppSizes.md, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white70, size: 18),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(chapter.flag,
                                        style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 8),
                                    Text(
                                      chapter.city,
                                      style: AppTypography.heading(
                                              color: Colors.white)
                                          .copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                Text(
                                  chapter.tagline,
                                  style: AppTypography.caption(
                                          color: Colors.white60)
                                      .copyWith(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          // Coin badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
                              border: Border.all(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monetization_on,
                                    color: AppColors.accent, size: 15),
                                const SizedBox(width: 3),
                                Text(
                                  '${progress.coins}',
                                  style: AppTypography.caption(
                                          color: AppColors.accent)
                                      .copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),

                    // ── Progress summary ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md, vertical: AppSizes.sm),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$solved / $total puzzles solved',
                              style: AppTypography.caption(
                                  color: Colors.white70),
                            ),
                            const Spacer(),
                            // Dot progress
                            Row(
                              children: List.generate(total, (i) {
                                final done = i < solved;
                                return Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: done
                                        ? AppColors.accent
                                        : Colors.white
                                            .withValues(alpha: 0.2),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),

                    // ── Puzzle grid ──────────────────────────────
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.lg, 0, AppSizes.lg, AppSizes.xxl),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.sm,
                          mainAxisSpacing: AppSizes.sm,
                          childAspectRatio: 1.35,
                        ),
                        itemCount: total,
                        itemBuilder: (context, i) {
                          final puzzle = chapter.puzzles[i];
                          final puzzleNum = i + 1;
                          final isComplete = progress.completedPuzzleIds
                              .contains(puzzle.id);
                          // Locked if previous puzzle not done (first is always open)
                          final isLocked = i > 0 &&
                              !progress.completedPuzzleIds
                                  .contains(chapter.puzzles[i - 1].id);

                          return _PuzzleCell(
                            puzzle: puzzle,
                            number: puzzleNum,
                            isComplete: isComplete,
                            isLocked: isLocked,
                            isCurrent: !isComplete && !isLocked,
                            index: i,
                            onTap: isLocked
                                ? null
                                : () => context.push(
                                    '/puzzle/$chapterId/$puzzleNum'),
                          ).animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 40 * i),
                              duration: 350.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              curve: Curves.easeOut);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Color> _gradientForChapter(String id) {
    const gradients = [
      [Color(0xFF3D2B8F), Color(0xFF7B5EA7)],
      [Color(0xFF0F4C81), Color(0xFF1D7EC2)],
      [Color(0xFF1A5C3A), Color(0xFF2E9E62)],
      [Color(0xFF7A3B00), Color(0xFFC4640A)],
      [Color(0xFF5C1A6B), Color(0xFF9B3DAF)],
      [Color(0xFF7A1A1A), Color(0xFFC03030)],
    ];
    final hash = id.codeUnits.fold(0, (a, b) => a + b);
    final picked = gradients[hash % gradients.length];
    return [picked[0], picked[1]];
  }
}

// ── Puzzle cell ───────────────────────────────────────────────────────────────

class _PuzzleCell extends StatelessWidget {
  final Puzzle puzzle;
  final int number;
  final bool isComplete;
  final bool isLocked;
  final bool isCurrent;
  final int index;
  final VoidCallback? onTap;

  const _PuzzleCell({
    required this.puzzle,
    required this.number,
    required this.isComplete,
    required this.isLocked,
    required this.isCurrent,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color numColor;

    if (isComplete) {
      borderColor = AppColors.accent;
      bgColor = AppColors.accent.withValues(alpha: 0.12);
      numColor = AppColors.accent;
    } else if (isCurrent) {
      borderColor = Colors.white.withValues(alpha: 0.5);
      bgColor = Colors.white.withValues(alpha: 0.08);
      numColor = Colors.white;
    } else {
      borderColor = Colors.white.withValues(alpha: 0.1);
      bgColor = Colors.white.withValues(alpha: 0.03);
      numColor = Colors.white24;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: borderColor, width: isComplete ? 2 : 1),
          boxShadow: isComplete
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : isCurrent
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Number or icon
            if (isComplete)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.star_rounded,
                    color: Colors.black87, size: 24),
              )
            else if (isLocked)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Colors.white24, size: 20),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: numColor,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            Text(
              'Puzzle $number',
              style: AppTypography.caption(
                color: isLocked ? Colors.white24 : Colors.white70,
              ).copyWith(fontWeight: FontWeight.w600),
            ),

            if (!isLocked)
              Text(
                '${puzzle.words.where((w) => !w.isBonus).length} words',
                style: AppTypography.caption(
                  color: isComplete ? AppColors.accent.withValues(alpha: 0.7)
                      : Colors.white38,
                ).copyWith(fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}
