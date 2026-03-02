// lib/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/weather_entity.dart';
import '../providers/weather_provider.dart';
import '../widgets/shared_widgets.dart';
import 'city_detail_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerCtrl;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    final cities = weather.cities;
    final overallCondition = cities.isNotEmpty ? cities[0].condition : 'Clear';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: WeatherTheme.getGradient(overallCondition, isDark),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              _DashboardHeader(
                ctrl: _headerCtrl,
                isDark: isDark,
                themeProvider: themeProvider,
              ),

              // ── Liste villes ───────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: cities.length,
                  itemBuilder: (_, i) => StaggeredEntry(
                    index: i,
                    baseDelay: const Duration(milliseconds: 80),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CityCard(
                        city: cities[i],
                        isDark: isDark,
                        onTap: () => _openDetail(context, cities[i]),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bouton Recommencer ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _RestartButton(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, WeatherEntity city) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => CityDetailScreen(city: city),
        transitionsBuilder: (_, a1, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

// ── Dashboard Header ─────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final AnimationController ctrl;
  final bool isDark;
  final ThemeProvider themeProvider;

  const _DashboardHeader({
    required this.ctrl,
    required this.isDark,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: ctrl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌍 Météo Mondiale',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  ),
                ),
                Text(
                  '5 villes · Temps réel',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ThemeToggle(
              isDark: isDark,
              onToggle: themeProvider.toggle,
            ),
          ],
        ),
      ),
    );
  }
}

// ── City Card ────────────────────────────────────────────────────────────────

class _CityCard extends StatelessWidget {
  final WeatherEntity city;
  final bool isDark;
  final VoidCallback onTap;

  const _CityCard({
    required this.city,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weatherColor = WeatherTheme.getColor(city.condition);
    final bgUrl = WeatherTheme.getUnsplashUrl(city.condition);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 120,
          child: Stack(
            children: [
              // Fond image floue
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: bgUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.darkSurface),
                  errorWidget: (_, __, ___) => Container(color: AppColors.darkSurface),
                ),
              ),

              // Overlay glassmorphism
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),

              // Barre colorée gauche
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 4,
                  color: weatherColor,
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    // Icône + ville
                    Expanded(
                      child: Row(
                        children: [
                          FloatingWidget(
                            amplitude: 4,
                            child: Text(
                              WeatherTheme.getEmoji(city.condition),
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    city.flag,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    city.cityName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _StatChip(
                                    icon: '💧',
                                    value: '${city.humidity}%',
                                    color: AppColors.rain,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    icon: '💨',
                                    value: '${city.windSpeed.toStringAsFixed(1)} m/s',
                                    color: AppColors.wind,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Température
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${city.temperature.toInt()}°',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -2,
                            shadows: [
                              Shadow(
                                color: weatherColor.withOpacity(0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          city.conditionDesc.isNotEmpty
                              ? city.conditionDesc
                              : city.condition,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;

  const _StatChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        '$icon $value',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Restart Button ───────────────────────────────────────────────────────────

class _RestartButton extends StatefulWidget {
  final bool isDark;
  const _RestartButton({required this.isDark});

  @override
  State<_RestartButton> createState() => _RestartButtonState();
}

class _RestartButtonState extends State<_RestartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: () => _restart(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [AppColors.darkAccent.withOpacity(0.2), AppColors.darkAccentSecondary.withOpacity(0.2)]
                  : [AppColors.lightAccent.withOpacity(0.15), AppColors.lightAccentSecondary.withOpacity(0.15)],
            ),
            border: Border.all(
              color: widget.isDark ? AppColors.darkAccent.withOpacity(0.4) : Colors.white.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔁', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                'Recommencer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? AppColors.darkAccent : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restart(BuildContext context) {
    context.read<WeatherProvider>().reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }
}
