import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/providers/audio_provider.dart';
import 'features/settings/viewmodel/settings_viewmodel.dart';
import 'features/chapter_select/view/chapter_select_screen.dart';
import 'features/puzzle/view/puzzle_screen.dart';
import 'features/postcard/view/postcard_reveal_screen.dart';
import 'features/settings/view/settings_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/profile/view/profile_screen.dart';
import 'features/puzzle_list/view/puzzle_list_screen.dart';

class WordSpyApp extends ConsumerStatefulWidget {
  const WordSpyApp({super.key});

  @override
  ConsumerState<WordSpyApp> createState() => _WordSpyAppState();
}

class _WordSpyAppState extends ConsumerState<WordSpyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playBgMusic();
    });
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/chapters',
          builder: (context, state) => const ChapterSelectScreen(),
        ),
        GoRoute(
          path: '/chapter/:chapterId',
          builder: (context, state) => PuzzleListScreen(
            chapterId: state.pathParameters['chapterId']!,
          ),
        ),
        GoRoute(
          path: '/puzzle/:chapterId/:puzzleNumber',
          builder: (context, state) => PuzzleScreen(
            chapterId: state.pathParameters['chapterId']!,
            puzzleNumber: int.parse(state.pathParameters['puzzleNumber']!),
          ),
        ),
        GoRoute(
          path: '/postcard/:chapterId',
          builder: (context, state) => PostcardRevealScreen(
            chapterId: state.pathParameters['chapterId']!,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(themeSettings.textScale),
      ),
      child: MaterialApp.router(
        title: 'Word Spy',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(themeSettings),
        routerConfig: _router,
      ),
    );
  }

  ThemeData _buildTheme(ThemeSettings settings) {
    final colorScheme = settings.highContrast
        ? const ColorScheme.dark(
            primary: AppColors.hcPrimary,
            secondary: AppColors.hcAccent,
            surface: AppColors.hcSurface,
            onSurface: AppColors.hcText,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: AppTypography.poppinsTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
