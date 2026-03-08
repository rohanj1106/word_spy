import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/hint.dart';
import '../../../core/models/word_placement.dart';
import '../../../core/providers/audio_provider.dart';
import '../../../core/providers/player_progress_provider.dart';
import '../viewmodel/puzzle_viewmodel.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  final String chapterId;
  final int puzzleNumber;

  const PuzzleScreen({
    super.key,
    required this.chapterId,
    required this.puzzleNumber,
  });

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  late AnimationController _coinPopController;
  late Animation<double> _coinFadeAnimation;
  late Animation<Offset> _coinSlideAnimation;

  String _coinPopText = '';

  (String, int) get _key => (widget.chapterId, widget.puzzleNumber);

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.03, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.03, 0), end: const Offset(-0.03, 0)),
          weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.03, 0), end: Offset.zero),
          weight: 1),
    ]).animate(CurvedAnimation(
        parent: _shakeController, curve: Curves.easeInOut));

    _coinPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _coinFadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
          parent: _coinPopController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
    _coinSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
        parent: _coinPopController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _coinPopController.dispose();
    super.dispose();
  }

  void _onDragEnd() {
    final vm = ref.read(puzzleProvider(_key).notifier);
    final coins = vm.submitSelection();

    if (coins != null) {
      ref.read(audioServiceProvider).playCoin();
      setState(() => _coinPopText = '+$coins');
      _coinPopController.forward(from: 0);

      // Show definition after a short delay
      final lastWord = ref.read(puzzleProvider(_key)).lastFoundWord;
      final puzzle = ref.read(puzzleProvider(_key)).puzzle;
      if (lastWord != null && puzzle != null) {
        final placement = puzzle.words
            .where((w) => w.word.word == lastWord)
            .firstOrNull;
        if (placement != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            _showDefinition(placement);
          });
        }
      }
    } else if (ref.read(puzzleProvider(_key)).selectedCells.isNotEmpty == false) {
      // Was non-empty before submit cleared it → wrong word
      _shakeController.forward(from: 0);
    }
  }

  void _showDefinition(WordPlacement placement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DefinitionSheet(placement: placement),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(puzzleProvider(_key));
    final vm = ref.read(puzzleProvider(_key).notifier);
    final coins = ref.watch(playerProgressProvider.select((p) => p.coins));

    ref.listen(puzzleProvider(_key), (prev, next) {
      if (!(prev?.puzzleComplete ?? false) && next.puzzleComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pushReplacement('/postcard/${widget.chapterId}');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          state.puzzle == null
              ? 'Loading...'
              : '${widget.chapterId.split('_').first.toUpperCase()} · Puzzle ${widget.puzzleNumber}',
          style: AppTypography.subheading(color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSizes.md),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 3),
                Text('$coins',
                    style: AppTypography.caption(color: AppColors.accent)
                        .copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
      body: state.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : state.puzzle == null
              ? const Center(child: Text('Puzzle not found'))
              : Stack(
                  children: [
                    Column(
                      children: [
                        // Postcard hint strip
                        if (state.puzzle!.postcardHint != null)
                          _PostcardHintStrip(
                              hint: state.puzzle!.postcardHint!),

                        const SizedBox(height: AppSizes.sm),

                        // Word search grid with shake animation
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md),
                            child: SlideTransition(
                              position: _shakeAnimation,
                              child: _WordSearchGrid(
                                grid: state.puzzle!.grid,
                                words: state.puzzle!.words,
                                selectedCells: state.selectedCells,
                                foundWords: state.foundWords,
                                hintedCells: state.hintedCells,
                                onDragStart: (row, col) {
                                  vm.clearSelection();
                                  vm.selectCell(row, col);
                                },
                                onDragUpdate: vm.selectCell,
                                onDragEnd: _onDragEnd,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSizes.sm),

                        // Words to find
                        Expanded(
                          flex: 3,
                          child: _WordsList(
                            words: state.puzzle!.words,
                            foundWords: state.foundWords,
                          ),
                        ),

                        // Hint bar
                        _HintBar(
                          coins: coins,
                          onHint: (type) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final result = await vm.useHint(type);
                            if (!mounted) return;
                            if (result == null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Not enough Travel Coins!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Hint revealed: $result'),
                                  backgroundColor: AppColors.accent,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: AppSizes.sm),
                      ],
                    ),

                    // Coin pop animation overlay
                    if (_coinPopText.isNotEmpty)
                      Positioned(
                        top: 120,
                        left: 0,
                        right: 0,
                        child: SlideTransition(
                          position: _coinSlideAnimation,
                          child: FadeTransition(
                            opacity: _coinFadeAnimation,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.md,
                                    vertical: AppSizes.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusPill),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _coinPopText,
                                  style: AppTypography.subheading(
                                          color: Colors.white)
                                      .copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

// ── Postcard hint strip ───────────────────────────────────────────────────────

class _PostcardHintStrip extends StatelessWidget {
  final String hint;
  const _PostcardHintStrip({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.sm),
      child: Row(
        children: [
          const Icon(Icons.mail_outline, color: AppColors.primary, size: 16),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              hint,
              style: AppTypography.caption(color: AppColors.primary)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Word search grid ──────────────────────────────────────────────────────────

class _WordSearchGrid extends StatefulWidget {
  final List<List<String>> grid;
  final List<WordPlacement> words;
  final List<(int, int)> selectedCells;
  final Set<String> foundWords;
  final Set<(int, int)> hintedCells;
  final void Function(int row, int col) onDragStart;
  final void Function(int row, int col) onDragUpdate;
  final void Function() onDragEnd;

  const _WordSearchGrid({
    required this.grid,
    required this.words,
    required this.selectedCells,
    required this.foundWords,
    required this.hintedCells,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<_WordSearchGrid> createState() => _WordSearchGridState();
}

class _WordSearchGridState extends State<_WordSearchGrid> {
  final _gridKey = GlobalKey();

  (int, int)? _cellAt(Offset localPosition) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final size = box.size;
    final rows = widget.grid.length;
    final cols = widget.grid.isEmpty ? 0 : widget.grid[0].length;
    if (rows == 0 || cols == 0) return null;

    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final col = (localPosition.dx / cellW).floor();
    final row = (localPosition.dy / cellH).floor();

    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return (row, col);
  }

  bool _isFound(int row, int col) {
    return widget.words
        .where((w) => widget.foundWords.contains(w.word.word))
        .any((w) => w.cells.contains((row, col)));
  }

  bool _isSelected(int row, int col) =>
      widget.selectedCells.contains((row, col));

  @override
  Widget build(BuildContext context) {
    final rows = widget.grid.length;
    final cols = widget.grid.isEmpty ? 0 : widget.grid[0].length;

    return AspectRatio(
      aspectRatio: cols / rows,
      child: GestureDetector(
        onPanStart: (d) {
          final cell = _cellAt(d.localPosition);
          if (cell != null) widget.onDragStart(cell.$1, cell.$2);
        },
        onPanUpdate: (d) {
          final cell = _cellAt(d.localPosition);
          if (cell != null) widget.onDragUpdate(cell.$1, cell.$2);
        },
        onPanEnd: (_) => widget.onDragEnd(),
        child: Container(
          key: _gridKey,
          child: Column(
            children: List.generate(rows, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(cols, (col) {
                    final letter = widget.grid[row][col];
                    final found = _isFound(row, col);
                    final selected = _isSelected(row, col);
                    final hinted = widget.hintedCells.contains((row, col));

                    final bgColor = found
                        ? AppColors.success.withValues(alpha: 0.25)
                        : hinted
                            ? AppColors.accent.withValues(alpha: 0.3)
                            : selected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.surface;
                    final borderColor = found
                        ? AppColors.success
                        : hinted
                            ? AppColors.accent
                            : selected
                                ? AppColors.primary
                                : AppColors.textHint.withValues(alpha: 0.3);
                    final textColor = found
                        ? AppColors.success
                        : hinted
                            ? AppColors.accent
                            : selected
                                ? AppColors.primary
                                : AppColors.textPrimary;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: borderColor,
                              width: found || selected || hinted ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: AppTypography.body(
                                color: textColor,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Words list ────────────────────────────────────────────────────────────────

class _WordsList extends StatelessWidget {
  final List<WordPlacement> words;
  final Set<String> foundWords;

  const _WordsList({required this.words, required this.foundWords});

  @override
  Widget build(BuildContext context) {
    final required = words.where((w) => !w.isBonus).toList();
    final bonus = words.where((w) => w.isBonus).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find these words',
              style: AppTypography.caption(color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.xs),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: required
                .map((w) => _WordChip(
                    placement: w,
                    found: foundWords.contains(w.word.word)))
                .toList(),
          ),
          if (bonus.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text('Bonus',
                style: AppTypography.caption(color: AppColors.accent)),
            const SizedBox(height: AppSizes.xs),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.xs,
              children: bonus
                  .map((w) => _WordChip(
                      placement: w,
                      found: foundWords.contains(w.word.word),
                      isBonus: true))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final WordPlacement placement;
  final bool found;
  final bool isBonus;

  const _WordChip({
    required this.placement,
    required this.found,
    this.isBonus = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBonus ? AppColors.accent : AppColors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: found ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: found ? color : AppColors.textHint.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        found ? placement.word.word : '${placement.word.word.length} letters',
        style: AppTypography.caption(
          color: found ? color : AppColors.textHint,
        ).copyWith(
          decoration: found ? TextDecoration.lineThrough : null,
          fontWeight: found ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

// ── Hint bar ─────────────────────────────────────────────────────────────────

class _HintBar extends StatelessWidget {
  final int coins;
  final void Function(HintType) onHint;

  const _HintBar({required this.coins, required this.onHint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _HintButton(
            icon: Icons.camera_alt_outlined,
            label: 'Snapshot',
            cost: Hint.snapshot.cost,
            coins: coins,
            onTap: () => onHint(HintType.snapshot),
          ),
          _HintButton(
            icon: Icons.search,
            label: 'Binoculars',
            cost: Hint.binoculars.cost,
            coins: coins,
            onTap: () => onHint(HintType.binoculars),
          ),
          _HintButton(
            icon: Icons.person_outline,
            label: 'Local Guide',
            cost: Hint.localGuide.cost,
            coins: coins,
            onTap: () => onHint(HintType.localGuide),
          ),
        ],
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int cost;
  final int coins;
  final VoidCallback onTap;

  const _HintButton({
    required this.icon,
    required this.label,
    required this.cost,
    required this.coins,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = coins >= cost;
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Opacity(
        opacity: canAfford ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.caption(color: AppColors.textSecondary)
                    .copyWith(fontSize: 10)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.accent, size: 10),
                const SizedBox(width: 1),
                Text('$cost',
                    style: AppTypography.caption(color: AppColors.accent)
                        .copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Definition sheet ──────────────────────────────────────────────────────────

class _DefinitionSheet extends StatelessWidget {
  final WordPlacement placement;
  const _DefinitionSheet({required this.placement});

  @override
  Widget build(BuildContext context) {
    final color = placement.isBonus ? AppColors.accent : AppColors.success;
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    placement.word.word,
                    style: AppTypography.heading(color: color),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    placement.isBonus ? 'Bonus +25' : '+10 coins',
                    style: AppTypography.caption(color: color)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              placement.word.partOfSpeech,
              style: AppTypography.caption(color: AppColors.textSecondary)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              placement.word.definition,
              style: AppTypography.body(color: AppColors.textPrimary)
                  .copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
