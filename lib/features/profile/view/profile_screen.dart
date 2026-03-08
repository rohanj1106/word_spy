import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/player_progress_provider.dart';
import '../../../core/services/chapter_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Journey',
          style: AppTypography.subheading(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin balance card
            _StatCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.accent, size: 40),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      '${progress.coins}',
                      style: AppTypography.display(color: AppColors.textPrimary)
                          .copyWith(fontSize: 48, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  'Travel Coins',
                  style: AppTypography.caption(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    children: [
                      Text(
                        '${progress.completedPuzzleIds.length}',
                        style: AppTypography.heading(color: AppColors.primary)
                            .copyWith(fontSize: 32, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Puzzles\nSolved',
                        style: AppTypography.caption(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _StatCard(
                    children: [
                      Text(
                        '${progress.earnedStamps.length}',
                        style: AppTypography.heading(color: AppColors.accent)
                            .copyWith(fontSize: 32, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Stamps\nEarned',
                        style: AppTypography.caption(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              'City Stamps',
              style: AppTypography.subheading(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSizes.sm),

            // Stamps grid — loaded async
            FutureBuilder(
              future: ChapterService.loadAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.lg),
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }
                final chapters = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSizes.sm,
                    mainAxisSpacing: AppSizes.sm,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, i) {
                    final chapter = chapters[i];
                    final hasStamp =
                        progress.earnedStamps.contains(chapter.id);
                    final solved =
                        progress.puzzlesCompletedInChapter(chapter.id);
                    return _StampTile(
                      flag: chapter.flag,
                      city: chapter.city,
                      hasStamp: hasStamp,
                      puzzlesSolved: solved,
                      totalPuzzles: chapter.puzzles.length,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final List<Widget> children;
  const _StatCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _StampTile extends StatelessWidget {
  final String flag;
  final String city;
  final bool hasStamp;
  final int puzzlesSolved;
  final int totalPuzzles;

  const _StampTile({
    required this.flag,
    required this.city,
    required this.hasStamp,
    required this.puzzlesSolved,
    required this.totalPuzzles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: hasStamp
              ? AppColors.accent
              : AppColors.textHint.withValues(alpha: 0.3),
          width: hasStamp ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(flag, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: AppSizes.xs),
                Text(
                  city,
                  style: AppTypography.caption(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$puzzlesSolved/$totalPuzzles',
                  style: AppTypography.caption(color: AppColors.textSecondary)
                      .copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          if (hasStamp)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
          if (!hasStamp && puzzlesSolved == 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(Icons.lock_outline,
                    color: AppColors.textHint, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
