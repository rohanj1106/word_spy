import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';
import '../viewmodel/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTypography.subheading(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Text(
            'Accessibility',
            style: AppTypography.caption(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.sm),

          _SettingsCard(
            children: [
              _SwitchTile(
                title: 'High Contrast',
                subtitle: 'Darker background with bolder colors',
                value: theme.highContrast,
                onChanged: (v) => notifier.setHighContrast(v),
              ),
              const Divider(height: 1),
              _SegmentTile(
                title: 'Font',
                options: const ['Standard', 'OpenDyslexic'],
                values: const ['poppins', 'opendyslexic'],
                selected: theme.fontPreference,
                onChanged: (v) => notifier.setFont(v),
              ),
              const Divider(height: 1),
              _TextScaleTile(
                currentScale: theme.textScale,
                onChanged: (v) => notifier.setTextScale(v),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.lg),

          Text(
            'About',
            style: AppTypography.caption(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.sm),

          _SettingsCard(
            children: [
              ListTile(
                title: Text('Version', style: AppTypography.body()),
                trailing: Text('0.1.0-alpha',
                    style: AppTypography.caption(
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: AppTypography.body()),
      subtitle: Text(subtitle,
          style: AppTypography.caption(color: AppColors.textSecondary)),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _SegmentTile extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentTile({
    required this.title,
    required this.options,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.body())),
          SegmentedButton<String>(
            segments: List.generate(
              options.length,
              (i) => ButtonSegment(value: values[i], label: Text(options[i])),
            ),
            selected: {selected},
            onSelectionChanged: (s) => onChanged(s.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextScaleTile extends StatelessWidget {
  final double currentScale;
  final ValueChanged<double> onChanged;

  const _TextScaleTile({
    required this.currentScale,
    required this.onChanged,
  });

  static const _scales = [0.85, 1.0, 1.15, 1.3];
  static const _labels = ['Small', 'Medium', 'Large', 'XL'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Text Size', style: AppTypography.body()),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<double>(
              segments: List.generate(
                _scales.length,
                (i) => ButtonSegment(
                    value: _scales[i], label: Text(_labels[i])),
              ),
              selected: {currentScale},
              onSelectionChanged: (s) => onChanged(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return null;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
