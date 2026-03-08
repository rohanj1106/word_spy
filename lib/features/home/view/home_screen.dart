import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_typography.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showComingSoon(BuildContext context, String provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          '$provider Login',
          style: AppTypography.subheading(color: AppColors.textPrimary),
        ),
        content: Text(
          '$provider sign-in is coming soon! For now, continue as a Guest — your progress is saved on this device.',
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0D4A), // very deep indigo
                  Color(0xFF3D2B8F), // primary indigo
                  Color(0xFF5C3D9E), // mid purple
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Decorative floating dots ─────────────────────────
          const Positioned.fill(child: _TravelDots()),

          // ── Content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Custom logo ──────────────────────────────────
                const _WordSpyLogo()
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: AppSizes.lg),

                // Tagline stamp
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg, vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18), width: 1),
                  ),
                  child: Text(
                    '🌍  Decode hidden messages from cities around the world',
                    style: AppTypography.caption(
                            color: Colors.white.withValues(alpha: 0.85))
                        .copyWith(height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 600.ms),

                const Spacer(flex: 2),

                // ── Login card ───────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Postmark decorative line
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.accent, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🕵️',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, Traveller',
                                  style: AppTypography.subheading(
                                      color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Sign in to save your progress',
                                  style: AppTypography.caption(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Google
                      _SocialButton(
                        label: 'Continue with Google',
                        icon: const _GoogleIcon(),
                        onTap: () => _showComingSoon(context, 'Google'),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Facebook
                      _SocialButton(
                        label: 'Continue with Facebook',
                        icon: const Icon(Icons.facebook_rounded,
                            color: Color(0xFF1877F2), size: 22),
                        onTap: () => _showComingSoon(context, 'Facebook'),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Apple
                      _SocialButton(
                        label: 'Continue with Apple',
                        icon: const Icon(Icons.apple_rounded,
                            color: Colors.black87, size: 22),
                        onTap: () => _showComingSoon(context, 'Apple'),
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: AppColors.textHint
                                      .withValues(alpha: 0.3))),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm),
                            child: Text('or',
                                style: AppTypography.caption(
                                    color: AppColors.textHint)),
                          ),
                          Expanded(
                              child: Divider(
                                  color: AppColors.textHint
                                      .withValues(alpha: 0.3))),
                        ],
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Guest — fully functional
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/chapters'),
                          icon: const Icon(Icons.explore_outlined, size: 20),
                          label: Text(
                            'Play as Guest',
                            style: AppTypography.body(color: Colors.white)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Guest progress is saved on this device only.',
                        style:
                            AppTypography.caption(color: AppColors.textHint),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 700.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOut),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Word Spy Logo ─────────────────────────────────────────────────────────────

class _WordSpyLogo extends StatelessWidget {
  const _WordSpyLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon mark: envelope with magnifying glass
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: _LogoPainter()),
        ),
        const SizedBox(height: 16),
        // Wordmark
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF4A61D), Color(0xFFFFC84A), Color(0xFFF4A61D)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: const Text(
            'WORD SPY',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 1,
              width: 28,
              color: Colors.white24,
            ),
            const SizedBox(width: 8),
            Text(
              'THE POSTCARD TRAVELLER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 1,
              width: 28,
              color: Colors.white24,
            ),
          ],
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Outer glow ring ──────────────────────────────────────
    final glowPaint = Paint()
      ..color = const Color(0xFFF4A61D).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy), 46, glowPaint);

    // ── Circle background ─────────────────────────────────────
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFF6A52C4), Color(0xFF2A1A6E)],
      ).createShader(Rect.fromCircle(
          center: Offset(cx, cy), radius: 44));
    canvas.drawCircle(Offset(cx, cy), 44, bgPaint);

    // ── Ring border ───────────────────────────────────────────
    final borderPaint = Paint()
      ..color = const Color(0xFFF4A61D).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), 44, borderPaint);

    // ── Envelope body ─────────────────────────────────────────
    final envLeft = cx - 22.0;
    final envTop = cy - 13.0;
    final envRight = cx + 22.0;
    final envBottom = cy + 13.0;
    final envRect =
        RRect.fromLTRBR(envLeft, envTop, envRight, envBottom,
            const Radius.circular(4));

    final envPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(envRect, envPaint);

    final envBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(envRect, envBorder);

    // ── Envelope flap (V) ──────────────────────────────────────
    final flapPath = Path()
      ..moveTo(envLeft, envTop)
      ..lineTo(cx, cy - 1)
      ..lineTo(envRight, envTop);
    canvas.drawPath(flapPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round);

    // ── Magnifying glass (bottom-right) ───────────────────────
    final mgCx = cx + 16.0;
    final mgCy = cy + 16.0;
    const mgR = 11.0;

    // White circle fill behind glass
    canvas.drawCircle(Offset(mgCx, mgCy), mgR + 1,
        Paint()..color = const Color(0xFF2A1A6E));

    // Gold glass circle
    final glassPaint = Paint()
      ..color = const Color(0xFFF4A61D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(mgCx, mgCy), mgR, glassPaint);

    // Glass lens fill (subtle)
    canvas.drawCircle(
        Offset(mgCx, mgCy),
        mgR - 1.5,
        Paint()
          ..color = const Color(0xFFF4A61D).withValues(alpha: 0.12));

    // Inner shine on lens
    canvas.drawCircle(
        Offset(mgCx - 3, mgCy - 3),
        2.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4));

    // Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFF4A61D)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(mgCx + mgR * 0.68, mgCy + mgR * 0.68),
      Offset(mgCx + mgR * 1.55, mgCy + mgR * 1.55),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
              color: AppColors.textHint.withValues(alpha: 0.35), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          elevation: 0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: AppSizes.sm),
                Text(
                  label,
                  style: AppTypography.body(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            Positioned(
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  'Soon',
                  style: AppTypography.caption(color: AppColors.textHint)
                      .copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Decorative travel dots ────────────────────────────────────────────────────

class _TravelDots extends StatelessWidget {
  const _TravelDots();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotPatternPainter());
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Scattered decorative circles
    final dots = [
      (0.1, 0.1, 80.0), (0.9, 0.05, 60.0), (0.85, 0.3, 40.0),
      (0.05, 0.45, 100.0), (0.95, 0.55, 70.0), (0.15, 0.8, 55.0),
      (0.75, 0.85, 90.0), (0.5, 0.12, 30.0), (0.35, 0.92, 45.0),
    ];

    for (final (dx, dy, r) in dots) {
      canvas.drawCircle(
        Offset(size.width * dx, size.height * dy),
        r,
        paint,
      );
    }

    // Dotted line (travel path feel)
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (double x = 0; x < size.width; x += 12) {
      canvas.drawCircle(
        Offset(x, size.height * 0.38),
        1.5,
        linePaint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Google "G" icon ───────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final sw = size.width * 0.28;

    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.68),
        start, sweep, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.butt,
      );
    }

    const pi = 3.14159;
    arc(const Color(0xFF4285F4), -pi / 2, pi);
    arc(const Color(0xFF34A853), pi / 2, pi / 2);
    arc(const Color(0xFFFBBC05), pi, pi / 2);
    arc(const Color(0xFFEA4335), -pi, pi / 2);

    // White cutout for "G" crossbar gap
    canvas.drawLine(
      c, Offset(c.dx + r * 0.72, c.dy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = sw * 1.1
        ..strokeCap = StrokeCap.butt,
    );
    // Blue crossbar
    canvas.drawLine(
      Offset(c.dx + r * 0.05, c.dy), Offset(c.dx + r * 0.68, c.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
