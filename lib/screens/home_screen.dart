import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';
import '../services/speed_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Weather
  final WeatherService _weatherService = WeatherService();
  String _city = '--';
  String _weatherCondition = '--';
  double _temp = 0;
  bool _loadingWeather = true;

  // Steps
  int _steps = 0;

  // Speed
  final SpeedService _speedService = SpeedService();
  double _speed = 0;
  StreamSubscription<Position>? _positionStream;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Request location permission first
    bool locationGranted = await _speedService.requestPermission();

    // 2. Request activity recognition permission sequentially after location
    var activityStatus = await Permission.activityRecognition.status;
    if (activityStatus.isDenied) {
      activityStatus = await Permission.activityRecognition.request();
    }
    bool activityGranted = activityStatus.isGranted;

    // 3. Load weather (internally checks location again, but will return immediately since it's already requested)
    _loadWeather();

    // 4. Initialize speed if location permission is granted
    if (locationGranted) {
      _initSpeedOnly();
    }

    // 5. Initialize step counter if activity recognition is granted
    if (activityGranted) {
      _initStepsOnly();
    } else {
      debugPrint("ACTIVITY_RECOGNITION permission was not granted.");
    }
  }

  Future<void> _loadWeather() async {
    try {
      final data = await _weatherService.getWeather();
      if (!mounted) return;
      setState(() {
        _city = data['city'] ?? '--';
        _weatherCondition = data['weather'] ?? '--';
        _temp = (data['temp'] as num).toDouble();
        _loadingWeather = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _city = 'Không lấy được';
        _weatherCondition = 'N/A';
        _loadingWeather = false;
      });
    }
  }

  void _initStepsOnly() {
    final stream = Pedometer.stepCountStream;
    stream.listen(
      (StepCount event) {
        if (mounted) setState(() => _steps = event.steps);
      },
      onError: (error) {
        debugPrint("Pedometer stream error: $error");
      },
    );
  }

  void _initSpeedOnly() {
    _positionStream =
        _speedService.getPositionStream().listen((Position pos) {
      if (mounted) setState(() => _speed = pos.speed * 3.6);
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _animController.dispose();
    super.dispose();
  }

  IconData _weatherIcon(String c) {
    switch (c.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.bolt;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  List<Color> _weatherGradient(String c) {
    switch (c.toLowerCase()) {
      case 'clear':
        return [const Color(0xFFFF9A2E), const Color(0xFFFF5F00)];
      case 'clouds':
        return [const Color(0xFF5B7FD4), const Color(0xFF3A5AAC)];
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF3A7BD5), const Color(0xFF1A4FA0)];
      case 'thunderstorm':
        return [const Color(0xFF6A3DBB), const Color(0xFF3D1E7A)];
      case 'snow':
        return [const Color(0xFF8EC5FC), const Color(0xFF4FA8D1)];
      default:
        return [const Color(0xFF4776E6), const Color(0xFF1A3A9F)];
    }
  }

  String _movingStatus() {
    if (_speed > 12) return '🚗 Đang lái xe';
    if (_speed > 4) return '🚴 Đang chạy';
    if (_speed > 0.5) return '🚶 Đang đi bộ';
    return '🧍 Đứng yên';
  }

  @override
  Widget build(BuildContext context) {
    final gradColors = _weatherGradient(_weatherCondition);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xin chào 👋',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Weather Card ─────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: gradColors[0].withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _loadingWeather
                      ? const SizedBox(
                          height: 110,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.white),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        _city,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_temp.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _weatherCondition,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _weatherIcon(_weatherCondition),
                              size: 90,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 20),

                // ── Steps & Speed Row ────────────────────────────
                Row(
                  children: [
                    // Steps card
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.directions_walk_rounded,
                        iconColor: const Color(0xFF00E5A0),
                        glowColor: const Color(0xFF00E5A0),
                        title: 'Bước chân',
                        value: _formatNumber(_steps),
                        unit: 'bước hôm nay',
                        bgStart: const Color(0xFF0D2B22),
                        bgEnd: const Color(0xFF071A14),
                        borderColor: const Color(0xFF00E5A0),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Speed card
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.speed_rounded,
                        iconColor: const Color(0xFFFF6B6B),
                        glowColor: const Color(0xFFFF6B6B),
                        title: 'Tốc độ',
                        value: _speed.toStringAsFixed(1),
                        unit: 'km/h hiện tại',
                        bgStart: const Color(0xFF2B0D0D),
                        bgEnd: const Color(0xFF1A0707),
                        borderColor: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Activity Details Card ────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF131629),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bar_chart_rounded,
                                color: Color(0xFF6C63FF), size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Thống kê hoạt động',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ActivityRow(
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFFF6B35),
                        label: 'Calories tiêu thụ',
                        value:
                            '${(_steps * 0.04).toStringAsFixed(0)} kcal',
                      ),
                      const _Divider(),
                      _ActivityRow(
                        icon: Icons.straighten_rounded,
                        color: const Color(0xFF42A5F5),
                        label: 'Quãng đường',
                        value:
                            '${(_steps * 0.0008).toStringAsFixed(2)} km',
                      ),
                      const _Divider(),
                      _ActivityRow(
                        icon: Icons.directions_run_rounded,
                        color: const Color(0xFFAB47BC),
                        label: 'Trạng thái',
                        value: _movingStatus(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Daily Goal Progress ──────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1035), Color(0xFF0F0D24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '🎯 Mục tiêu hôm nay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_progressPercent()}%',
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_steps / 10,000 bước',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_steps / 10000).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor:
                              Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6C63FF)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return '$n';
  }

  int _progressPercent() {
    return ((_steps / 10000) * 100).clamp(0, 100).toInt();
  }
}

// ── Reusable widgets ───────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final String title;
  final String value;
  final String unit;
  final Color bgStart;
  final Color bgEnd;
  final Color borderColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.bgStart,
    required this.bgEnd,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgStart, bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style:
                TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: iconColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _ActivityRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white.withOpacity(0.06),
      height: 1,
    );
  }
}
