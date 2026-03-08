import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/chapter.dart';
import '../../../core/providers/player_progress_provider.dart';
import '../viewmodel/chapter_select_viewmodel.dart';

class ChapterSelectScreen extends ConsumerWidget {
  const ChapterSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chapterSelectProvider);
    final vm = ref.read(chapterSelectProvider.notifier);
    final progress = ref.watch(playerProgressProvider);
    final completedChapters = progress.earnedStamps.length;
    final totalChapters = state.chapters.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1F),
      body: Stack(
        children: [
          // ── Star map background ──────────────────────────────
          const Positioned.fill(child: _MapBackground()),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg, AppSizes.md, AppSizes.md, 0),
                  child: Row(
                    children: [
                      // Back
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white60, size: 16),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Destination',
                              style: AppTypography.subheading(
                                      color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '$completedChapters of $totalChapters cities explored',
                              style: AppTypography.caption(
                                  color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      // Coin pill
                      _GlassPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on,
                                color: AppColors.accent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.coins}',
                              style: AppTypography.caption(
                                      color: AppColors.accent)
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      _IconCircle(
                        icon: Icons.person_outline,
                        onTap: () => context.push('/profile'),
                      ),
                      _IconCircle(
                        icon: Icons.settings_outlined,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ── Journey progress bar ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg),
                  child: _JourneyProgressBar(
                    completed: completedChapters,
                    total: totalChapters,
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Destination cards ─────────────────────────
                Expanded(
                  child: state.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              AppSizes.lg, 0, AppSizes.lg, AppSizes.xxl),
                          itemCount: state.chapters.length,
                          itemBuilder: (context, i) {
                            final chapter = state.chapters[i];
                            final locked =
                                vm.isLocked(chapter, progress);
                            final completed =
                                vm.isCompleted(chapter, progress);
                            final solved =
                                vm.puzzlesCompleted(chapter, progress);
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSizes.md),
                              child: _DestinationCard(
                                chapter: chapter,
                                index: i,
                                locked: locked,
                                completed: completed,
                                puzzlesSolved: solved,
                                onTap: locked
                                    ? () => _showLockedDialog(
                                        context, chapter, vm)
                                    : () => context.push(
                                        '/chapter/${chapter.id}'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedDialog(
    BuildContext context,
    Chapter chapter,
    ChapterSelectNotifier vm,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1535),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(chapter.flag, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSizes.sm),
            Text(
              chapter.city,
              style: AppTypography.heading(color: Colors.white),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Spend ${chapter.coinsToUnlock} Travel Coins to unlock this destination.',
              style: AppTypography.body(
                  color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusPill)),
                    ),
                    child: Text('Not yet',
                        style: AppTypography.body(
                            color: Colors.white60)),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final success = await vm.unlockChapter(chapter);
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Not enough Travel Coins!')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.monetization_on, size: 16),
                    label: Text('${chapter.coinsToUnlock} coins'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusPill)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }
}

// ── Journey progress bar ──────────────────────────────────────────────────────

class _JourneyProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  const _JourneyProgressBar(
      {required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Text('🌍', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.1),
                    color: AppColors.accent,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            '$completed/$total cities',
            style: AppTypography.caption(color: Colors.white60)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Destination card ──────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final Chapter chapter;
  final int index;
  final bool locked;
  final bool completed;
  final int puzzlesSolved;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.chapter,
    required this.index,
    required this.locked,
    required this.completed,
    required this.puzzlesSolved,
    required this.onTap,
  });

  static const _themes = [
    (_CardTheme(
      grad: [Color(0xFF3D2B8F), Color(0xFF7B5EA7)],
      accent: Color(0xFFA78BFA),
    )),
    (_CardTheme(
      grad: [Color(0xFF0F4C81), Color(0xFF1D7EC2)],
      accent: Color(0xFF60C6FF),
    )),
    (_CardTheme(
      grad: [Color(0xFF1A5C3A), Color(0xFF2E9E62)],
      accent: Color(0xFF5DFFA8),
    )),
    (_CardTheme(
      grad: [Color(0xFF7A3B00), Color(0xFFC4640A)],
      accent: Color(0xFFFFB347),
    )),
    (_CardTheme(
      grad: [Color(0xFF5C1A6B), Color(0xFF9B3DAF)],
      accent: Color(0xFFE879F9),
    )),
    (_CardTheme(
      grad: [Color(0xFF7A1A1A), Color(0xFFC03030)],
      accent: Color(0xFFFF8080),
    )),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = _themes[index % _themes.length];
    final total = chapter.puzzles.length;
    final ratio = total > 0 ? puzzlesSolved / total : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (locked
                      ? Colors.black
                      : theme.grad[0])
                  .withValues(alpha: locked ? 0.3 : 0.5),
              blurRadius: locked ? 8 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ── Gradient background ──────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: locked
                        ? [
                            const Color(0xFF1C1C2E),
                            const Color(0xFF2A2A40),
                          ]
                        : theme.grad,
                  ),
                ),
              ),

              // ── Decorative circles ───────────────────────
              if (!locked) ...[
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ],

              // ── Card content ────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: flag + chapter number + status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Big flag
                        Text(
                          chapter.flag,
                          style: TextStyle(
                              fontSize: locked ? 36 : 48),
                        ),
                        const Spacer(),
                        // Chapter number badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusPill),
                          ),
                          child: Text(
                            'Chapter ${index + 1}',
                            style: AppTypography.caption(
                                    color: Colors.white60)
                                .copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (completed) ...[
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.star_rounded,
                                color: Colors.black87, size: 16),
                          ),
                        ],
                        if (locked) ...[
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded,
                                color: Colors.white38, size: 14),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // City + country
                    Text(
                      chapter.city,
                      style: AppTypography.heading(
                              color: locked
                                  ? Colors.white38
                                  : Colors.white)
                          .copyWith(
                              fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      chapter.country,
                      style: AppTypography.caption(
                          color: locked
                              ? Colors.white24
                              : Colors.white60),
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // Tagline
                    Text(
                      chapter.tagline,
                      style: AppTypography.caption(
                          color: locked
                              ? Colors.white24
                              : theme.accent.withValues(alpha: 0.9))
                          .copyWith(fontStyle: FontStyle.italic),
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Bottom: puzzle dots + progress text
                    if (locked)
                      _LockedRow(cost: chapter.coinsToUnlock)
                    else
                      _PuzzleDotsRow(
                        solved: puzzlesSolved,
                        total: total,
                        ratio: ratio,
                        accent: theme.accent,
                        completed: completed,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
          .slideY(begin: 0.12, curve: Curves.easeOut),
    );
  }
}

class _CardTheme {
  final List<Color> grad;
  final Color accent;
  const _CardTheme({required this.grad, required this.accent});
}

// ── Puzzle dots ───────────────────────────────────────────────────────────────

class _PuzzleDotsRow extends StatelessWidget {
  final int solved;
  final int total;
  final double ratio;
  final Color accent;
  final bool completed;

  const _PuzzleDotsRow({
    required this.solved,
    required this.total,
    required this.ratio,
    required this.accent,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dot indicators
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(total, (i) {
              final done = i < solved;
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? accent
                      : Colors.white.withValues(alpha: 0.2),
                  boxShadow: done
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.5),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        // Progress text
        Text(
          completed
              ? '✓ Done'
              : solved == 0
                  ? 'Start!'
                  : '$solved/$total',
          style: AppTypography.caption(
            color: completed ? AppColors.accent : Colors.white70,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ── Locked row ────────────────────────────────────────────────────────────────

class _LockedRow extends StatelessWidget {
  final int cost;
  const _LockedRow({required this.cost});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.lock_rounded, color: Colors.white24, size: 14),
        const SizedBox(width: AppSizes.xs),
        Text(
          'Unlock for $cost Travel Coins',
          style: AppTypography.caption(color: Colors.white38)
              .copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// ── Glass pill ────────────────────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}

// ── Icon circle ───────────────────────────────────────────────────────────────

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white54, size: 18),
      ),
    );
  }
}

// ── Star map background ───────────────────────────────────────────────────────

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarMapPainter());
  }
}

class _StarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines (longitude/latitude style)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const cols = 8;
    const rows = 14;
    for (int i = 0; i <= cols; i++) {
      final x = size.width * i / cols;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int j = 0; j <= rows; j++) {
      final y = size.height * j / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Star dots
    final starPaint = Paint()..style = PaintingStyle.fill;
    final stars = [
      (0.05, 0.08, 1.5, 0.8), (0.18, 0.03, 1.0, 0.5),
      (0.35, 0.12, 2.0, 0.9), (0.6, 0.05, 1.2, 0.6),
      (0.82, 0.09, 1.8, 0.8), (0.92, 0.15, 1.0, 0.4),
      (0.12, 0.22, 1.5, 0.7), (0.45, 0.18, 1.0, 0.5),
      (0.72, 0.25, 2.0, 0.9), (0.88, 0.3, 1.2, 0.5),
      (0.25, 0.35, 1.8, 0.8), (0.55, 0.4, 1.0, 0.4),
      (0.78, 0.45, 1.5, 0.7), (0.08, 0.5, 1.2, 0.5),
      (0.4, 0.55, 2.0, 0.9), (0.65, 0.6, 1.0, 0.4),
      (0.9, 0.65, 1.8, 0.8), (0.2, 0.7, 1.5, 0.6),
      (0.5, 0.75, 1.0, 0.5), (0.75, 0.8, 2.0, 0.9),
      (0.15, 0.88, 1.2, 0.5), (0.42, 0.92, 1.8, 0.8),
      (0.68, 0.95, 1.0, 0.4), (0.95, 0.88, 1.5, 0.7),
    ];

    for (final (dx, dy, r, a) in stars) {
      starPaint.color = Colors.white.withValues(alpha: a * 0.6);
      canvas.drawCircle(
        Offset(size.width * dx, size.height * dy),
        r,
        starPaint,
      );
    }

    // Subtle top vignette
    final vignette = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D0B1F).withValues(alpha: 0.0),
          const Color(0xFF0D0B1F).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width,
          size.height * 0.3));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
