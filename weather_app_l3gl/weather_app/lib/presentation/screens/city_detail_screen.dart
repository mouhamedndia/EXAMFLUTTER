// lib/presentation/screens/city_detail_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/weather_entity.dart';
import '../providers/weather_provider.dart';
import '../widgets/shared_widgets.dart';

class CityDetailScreen extends StatefulWidget {
  final WeatherEntity city;

  const CityDetailScreen({super.key, required this.city});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _sunCtrl;
  final _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    _sunCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _sunCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    final city = widget.city;
    final weatherColor = WeatherTheme.getColor(city.condition);
    final bgGradient = WeatherTheme.getGradient(city.condition, isDark);
    final bgUrl = WeatherTheme.getUnsplashUrl(city.condition);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar avec photo de fond ─────────────────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkScaffold : bgGradient.last,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ThemeToggle(isDark: isDark, onToggle: themeProvider.toggle),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de fond
                  CachedNetworkImage(
                    imageUrl: bgUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: bgGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: bgGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Contenu AppBar
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Icône levitante
                            FloatingWidget(
                              amplitude: 8,
                              child: Text(
                                WeatherTheme.getEmoji(city.condition),
                                style: const TextStyle(fontSize: 64),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${city.flag} ${city.cityName}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    city.conditionDesc.isNotEmpty
                                        ? city.conditionDesc
                                        : city.condition,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Température
                            Text(
                              '${city.temperature.toInt()}°C',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -3,
                                shadows: [
                                  Shadow(
                                    color: weatherColor.withOpacity(0.6),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Badges rapides
                        Row(
                          children: [
                            _QuickBadge(
                              label: 'Ressenti',
                              value: '${city.feelsLike.toInt()}°',
                              color: weatherColor,
                            ),
                            const SizedBox(width: 8),
                            _QuickBadge(
                              label: 'Max',
                              value: '${city.tempMax.toInt()}°',
                              color: AppColors.sun,
                            ),
                            const SizedBox(width: 8),
                            _QuickBadge(
                              label: 'Min',
                              value: '${city.tempMin.toInt()}°',
                              color: AppColors.snow,
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

          // ── Corps ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [AppColors.darkScaffold, AppColors.darkScaffold]
                      : [AppColors.lightScaffold, AppColors.lightScaffold],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // ── Stats 3×2 ────────────────────────────────
                  StaggeredEntry(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 16),
                            child: SectionTitle(
                              title: 'Conditions actuelles',
                              accentColor: weatherColor,
                            ),
                          ),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.0,
                            children: [
                              _StatCard(
                                emoji: '💧',
                                label: 'Humidité',
                                value: '${city.humidity}%',
                                color: AppColors.rain,
                                isDark: isDark,
                              ),
                              _StatCard(
                                emoji: '💨',
                                label: 'Vent',
                                value: '${city.windSpeed.toStringAsFixed(1)} m/s',
                                color: AppColors.wind,
                                isDark: isDark,
                              ),
                              _StatCard(
                                emoji: '🌡️',
                                label: 'Pression',
                                value: '${city.pressure} hPa',
                                color: weatherColor,
                                isDark: isDark,
                              ),
                              _StatCard(
                                emoji: '👁️',
                                label: 'Visibilité',
                                value: '${(city.visibility / 1000).toStringAsFixed(1)} km',
                                color: AppColors.cloudy,
                                isDark: isDark,
                              ),
                              _StatCard(
                                emoji: '🌡️',
                                label: 'Ressenti',
                                value: '${city.feelsLike.toInt()}°C',
                                color: AppColors.sun,
                                isDark: isDark,
                              ),
                              _StatCard(
                                emoji: '📍',
                                label: 'Coordonnées',
                                value: '${city.lat.toStringAsFixed(1)}°N',
                                color: AppColors.wind,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Arc solaire ──────────────────────────────
                  StaggeredEntry(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 16),
                            child: SectionTitle(
                              title: 'Arc solaire',
                              accentColor: AppColors.sun,
                            ),
                          ),
                          _SunArcCard(city: city, isDark: isDark, sunCtrl: _sunCtrl),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Carte OpenStreetMap ──────────────────────
                  StaggeredEntry(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 16),
                            child: SectionTitle(
                              title: 'Localisation',
                              accentColor: weatherColor,
                            ),
                          ),
                          _MapCard(
                            city: city,
                            isDark: isDark,
                            mapCtrl: _mapCtrl,
                            weatherColor: weatherColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Badge ──────────────────────────────────────────────────────────────

class _QuickBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.4)),
        backdropFilter: null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sun Arc Card ─────────────────────────────────────────────────────────────

class _SunArcCard extends StatelessWidget {
  final WeatherEntity city;
  final bool isDark;
  final AnimationController sunCtrl;

  const _SunArcCard({
    required this.city,
    required this.isDark,
    required this.sunCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final sunrise = city.sunrise + city.timezone;
    final sunset = city.sunset + city.timezone;
    final dayLen = sunset - sunrise;
    final elapsed = (now + city.timezone - sunrise).clamp(0, dayLen);
    final dayProgress = dayLen > 0 ? elapsed / dayLen : 0.5;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: sunCtrl,
            builder: (_, __) => CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _SunArcPainter(
                progress: dayProgress.toDouble(),
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SunTime(
                label: '🌅 Lever',
                time: _formatTime(city.sunrise, city.timezone),
                isDark: isDark,
              ),
              _SunTime(
                label: '🌇 Coucher',
                time: _formatTime(city.sunset, city.timezone),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int unix, int tz) {
    final dt = DateTime.fromMillisecondsSinceEpoch((unix + tz) * 1000, isUtc: true);
    return DateFormat('HH:mm').format(dt);
  }
}

class _SunTime extends StatelessWidget {
  final String label;
  final String time;
  final bool isDark;

  const _SunTime({required this.label, required this.time, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SunArcPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.9;
    final r = size.width * 0.42;

    // Arc fond
    final trackPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Arc progression
    final progressPaint = Paint()
      ..color = AppColors.sun
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );

    // Position soleil
    final angle = math.pi + math.pi * progress;
    final sunX = cx + r * math.cos(angle);
    final sunY = cy + r * math.sin(angle);

    // Halo
    final haloPaint = Paint()
      ..color = AppColors.sun.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(sunX, sunY), 16, haloPaint);

    // Soleil
    final sunPaint = Paint()
      ..color = AppColors.sun
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 10, sunPaint);

    // Centre blanc
    final whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 4, whitePaint);

    // Ligne horizon
    final horizonPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(cx - r - 10, cy),
      Offset(cx + r + 10, cy),
      horizonPaint,
    );
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}

// ── Map Card avec flutter_map (OpenStreetMap GRATUIT) ────────────────────────

class _MapCard extends StatelessWidget {
  final WeatherEntity city;
  final bool isDark;
  final MapController mapCtrl;
  final Color weatherColor;

  const _MapCard({
    required this.city,
    required this.isDark,
    required this.mapCtrl,
    required this.weatherColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Carte OpenStreetMap — 100% gratuit, zéro clé API !
          SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: mapCtrl,
              options: MapOptions(
                initialCenter: LatLng(city.lat, city.lon),
                initialZoom: 11,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: isDark ? ['a', 'b', 'c'] : [],
                  userAgentPackageName: 'com.l3gl.weather_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(city.lat, city.lon),
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: weatherColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${city.temperature.toInt()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 12,
                            color: weatherColor,
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: weatherColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge ville flottant
          Positioned(
            top: 12,
            left: 12,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(city.flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    city.cityName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Boutons zoom custom
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _ZoomBtn(
                  icon: Icons.add,
                  isDark: isDark,
                  onTap: () => mapCtrl.move(
                    mapCtrl.camera.center,
                    mapCtrl.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: 6),
                _ZoomBtn(
                  icon: Icons.remove,
                  isDark: isDark,
                  onTap: () => mapCtrl.move(
                    mapCtrl.camera.center,
                    mapCtrl.camera.zoom - 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _ZoomBtn({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 10,
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}
