// lib/presentation/screens/loading_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/weather_repository.dart';
import '../providers/weather_provider.dart';
import '../widgets/shared_widgets.dart';
import 'dashboard_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _ring1Ctrl;
  late AnimationController _ring2Ctrl;
  late AnimationController _messageCtrl;

  int _messageIndex = 0;
  final _messages = [
    '🌍 Nous téléchargeons les données…',
    '🛰️ Connexion aux satellites météo…',
    '📡 C\'est presque fini…',
    '⏳ Plus que quelques secondes…',
    '✨ Finalisation en cours…',
  ];

  @override
  void initState() {
    super.initState();
    _ring1Ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _ring2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _messageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _cycleMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather();
    });
  }

  void _cycleMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;
      await _messageCtrl.forward();
      if (!mounted) break;
      setState(() { _messageIndex = (_messageIndex + 1) % _messages.length; });
      _messageCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _ring1Ctrl.dispose(); _ring2Ctrl.dispose(); _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    if (weather.status == WeatherStatus.loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, a1, a2) => const DashboardScreen(),
            transitionsBuilder: (_, a1, __, child) => FadeTransition(opacity: a1, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ));
        }
      });
    }

    final progress = weather.progress;
    final gradientColors = _getGradient(progress, isDark);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                StaggeredEntry(
                  child: Text('Chargement des données',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : Colors.white)),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 220, height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ring1Ctrl,
                        builder: (_, __) => CustomPaint(
                          size: const Size(220, 220),
                          painter: _RingPainter(
                            progress: progress,
                            rotation: _ring1Ctrl.value * 2 * math.pi,
                            rotation2: -_ring2Ctrl.value * 2 * math.pi,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress * 100),
                            duration: const Duration(milliseconds: 400),
                            builder: (_, val, __) => Text('${val.toInt()}%',
                              style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkAccent : Colors.white, letterSpacing: -2)),
                          ),
                          Text('${weather.loadedCount}/${weather.totalCount} villes',
                            style: TextStyle(fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _messageCtrl,
                  builder: (_, __) => Opacity(
                    opacity: 1 - _messageCtrl.value,
                    child: Text(_messages[_messageIndex],
                      style: TextStyle(fontSize: 15,
                        color: isDark ? AppColors.darkTextSecondary : Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: WeatherRepository.cities.length,
                    itemBuilder: (_, i) {
                      final cityName = WeatherRepository.cities[i]['name']!;
                      final flag = WeatherRepository.cities[i]['flag']!;
                      final isLoaded = i < weather.loadedCount;
                      return StaggeredEntry(
                        index: i,
                        baseDelay: const Duration(milliseconds: 80),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            opacity: isDark ? 0.06 : 0.3,
                            child: Row(
                              children: [
                                Text(flag, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(cityName,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : Colors.white))),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: isLoaded
                                    ? _CheckMark(key: ValueKey('check_$i'))
                                    : SizedBox(key: ValueKey('wait_$i'), width: 24, height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2,
                                          color: isDark ? AppColors.darkTextSecondary : Colors.white54)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (weather.status == WeatherStatus.error) ...[
                  const SizedBox(height: 16),
                  _ErrorRetry(isDark: isDark),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradient(double p, bool isDark) {
    if (isDark) {
      return [
        Color.lerp(const Color(0xFF050510), const Color(0xFF0A1020), p)!,
        Color.lerp(const Color(0xFF0A0A20), const Color(0xFF0F1530), p)!,
        Color.lerp(const Color(0xFF050510), const Color(0xFF050A20), p)!,
      ];
    }
    return [
      Color.lerp(const Color(0xFF2171C7), const Color(0xFF006B54), p)!,
      Color.lerp(const Color(0xFF4A90D9), const Color(0xFF00A880), p)!,
      Color.lerp(const Color(0xFF1A5FA8), const Color(0xFF005040), p)!,
    ];
  }
}

class _CheckMark extends StatefulWidget {
  const _CheckMark({super.key});
  @override
  State<_CheckMark> createState() => _CheckMarkState();
}

class _CheckMarkState extends State<_CheckMark> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 24, height: 24,
        decoration: const BoxDecoration(color: Color(0xFF00C896), shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final bool isDark;
  const _ErrorRetry({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('❌', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text('Erreur de connexion. Vérifiez votre réseau.',
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.white, fontSize: 14))),
          TextButton(
            onPressed: () => context.read<WeatherProvider>().loadWeather(),
            child: const Text('Réessayer 🔄'),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress, rotation, rotation2;
  final bool isDark;

  _RingPainter({required this.progress, required this.rotation, required this.rotation2, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r1 = size.width / 2 - 10;
    final r2 = size.width / 2 - 28;
    final accent = isDark ? AppColors.darkAccent : Colors.white;

    canvas.drawCircle(center, r1, Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 14..style = PaintingStyle.stroke);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r1), -math.pi / 2, sweepAngle, false,
      Paint()..color = accent.withOpacity(0.3)..strokeWidth = 24..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawArc(Rect.fromCircle(center: center, radius: r1), -math.pi / 2, sweepAngle, false,
      Paint()..color = accent..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    final ring2Paint = Paint()
      ..color = (isDark ? AppColors.darkAccentSecondary : Colors.white).withOpacity(0.3)
      ..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r2), rotation2, math.pi * 0.6, false, ring2Paint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r2), rotation2 + math.pi, math.pi * 0.4, false, ring2Paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => true;
}
