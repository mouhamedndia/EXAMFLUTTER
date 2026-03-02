// lib/presentation/screens/home_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/weather_provider.dart';
import '../widgets/shared_widgets.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _globeCtrl;
  late AnimationController _bgCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _globeRotate;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _globeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _globeRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(_globeCtrl);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _globeCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color.lerp(const Color(0xFF050510), const Color(0xFF0A1020), _bgCtrl.value)!,
                      Color.lerp(const Color(0xFF0A0A20), const Color(0xFF0F1530), _bgCtrl.value)!,
                      Color.lerp(const Color(0xFF050510), const Color(0xFF0A0520), _bgCtrl.value)!,
                    ]
                  : [
                      Color.lerp(const Color(0xFFF5F7FF), const Color(0xFFE8EEFF), _bgCtrl.value)!,
                      Color.lerp(const Color(0xFFEEF2FF), const Color(0xFFDDE8FF), _bgCtrl.value)!,
                      Color.lerp(const Color(0xFFF5F7FF), const Color(0xFFEAF0FF), _bgCtrl.value)!,
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Header avec toggle ──────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WeatherApp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                        ),
                      ),
                      ThemeToggle(
                        isDark: isDark,
                        onToggle: themeProvider.toggle,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Globe animé ────────────────────────────
                      AnimatedBuilder(
                        animation: _globeRotate,
                        builder: (_, __) => CustomPaint(
                          size: const Size(200, 200),
                          painter: _GlobePainter(
                            rotation: _globeRotate.value,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Logo / Titre ───────────────────────────
                      AnimatedBuilder(
                        animation: _logoCtrl,
                        builder: (_, child) => FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🌤️ Météo Mondiale',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Découvrez le temps en temps réel\ndans les plus grandes villes du monde',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── Chips villes ───────────────────────────
                      StaggeredEntry(
                        index: 1,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _CityChip(label: '🇸🇳 Dakar', isDark: isDark),
                            _CityChip(label: '🇫🇷 Paris', isDark: isDark),
                            _CityChip(label: '🇺🇸 New York', isDark: isDark),
                            _CityChip(label: '🇯🇵 Tokyo', isDark: isDark),
                            _CityChip(label: '🇬🇧 London', isDark: isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── Bouton CTA ─────────────────────────────
                      StaggeredEntry(
                        index: 2,
                        child: ShimmerButton(
                          label: '🚀 Découvrir la météo',
                          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                          onTap: () => _launchExperience(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchExperience(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => const LoadingScreen(),
        transitionsBuilder: (_, a1, __, child) => FadeTransition(
          opacity: a1,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

// ── City Chip ────────────────────────────────────────────────────────────────

class _CityChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _CityChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.7),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}

// ── Globe Painter ─────────────────────────────────────────────────────────────

class _GlobePainter extends CustomPainter {
  final double rotation;
  final bool isDark;

  _GlobePainter({required this.rotation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Lueur
    final glowPaint = Paint()
      ..color = (isDark ? AppColors.darkAccent : AppColors.lightAccent)
          .withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius + 15, glowPaint);

    // Fond globe
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0xFF1A2A4A), const Color(0xFF0A1020)]
            : [const Color(0xFF4A90D9), const Color(0xFF2171C7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Lignes de latitude
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 5; i++) {
      final y = center.dy - radius + (2 * radius * i / 5);
      final halfWidth = math.sqrt(math.max(0, radius * radius - math.pow(y - center.dy, 2)));
      canvas.drawLine(
        Offset(center.dx - halfWidth, y),
        Offset(center.dx + halfWidth, y),
        linePaint,
      );
    }

    // Méridiens animés
    for (int i = 0; i < 6; i++) {
      final angle = rotation + (i * math.pi / 3);
      final path = Path();
      bool first = true;
      for (int deg = -90; deg <= 90; deg += 2) {
        final rad = deg * math.pi / 180;
        final x = center.dx + radius * math.sin(angle) * math.cos(rad);
        final y = center.dy + radius * math.sin(rad);
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, linePaint);
    }

    // Bordure
    final borderPaint = Paint()
      ..color = (isDark ? AppColors.darkAccent : AppColors.lightAccent).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, borderPaint);

    // Reflet
    final reflectPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.3),
        width: radius * 0.6,
        height: radius * 0.35,
      ),
      reflectPaint,
    );
  }

  @override
  bool shouldRepaint(_GlobePainter old) =>
      old.rotation != rotation || old.isDark != isDark;
}
