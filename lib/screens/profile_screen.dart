import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _runs = [];
  bool _loading = true;

  double _totalDistance = 0;
  int _totalCalories = 0;
  int _totalSteps = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadHistory();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final data = await DatabaseHelper.instance.getRunHistory(widget.username);
    if (!mounted) return;

    double dist = 0;
    int cal = 0;
    int stp = 0;

    for (final item in data) {
      dist += (item['distance'] as num?)?.toDouble() ?? 0.0;
      cal += (item['calories'] as int?) ?? 0;
      stp += (item['steps'] as int?) ?? 0;
    }

    setState(() {
      _runs = data;
      _totalDistance = dist;
      _totalCalories = cal;
      _totalSteps = stp;
      _loading = false;
    });

    _animController.forward(from: 0);
  }

  String _formatDate(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} • $hour:$minute';
  }

  void _showAddRunDialog() {
    final titleController = TextEditingController(text: 'Chạy bộ chiều');
    final distanceController = TextEditingController(text: '2.5');
    final durationController = TextEditingController(text: '20 phút');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131629),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.directions_run_rounded, color: Color(0xFF00E5A0)),
            SizedBox(width: 8),
            Text(
              'Lưu buổi chạy mới',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Tên hoạt động'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Quãng đường (km)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Thời gian (ví dụ: 25 phút)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final title = titleController.text.trim();
              final dist = double.tryParse(distanceController.text.trim()) ?? 1.0;
              final dur = durationController.text.trim();
              final steps = (dist / 0.0008).round();
              final cal = (steps * 0.04).round();

              await DatabaseHelper.instance.insertRun(
                username: widget.username,
                title: title.isEmpty ? 'Chạy bộ' : title,
                distance: dist,
                steps: steps,
                calories: cal,
                duration: dur.isEmpty ? '20 phút' : dur,
                avgSpeed: 7.5,
              );

              if (mounted) {
                Navigator.pop(ctx);
                _loadHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu buổi chạy vào lịch sử!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Lưu buổi tập'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131629),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              )
            : FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header Profile ───────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF00E5A0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.username.isNotEmpty
                                    ? widget.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5A0).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🏃 Vận động viên FitTrack',
                                    style: TextStyle(
                                      color: Color(0xFF00E5A0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _confirmLogout,
                            icon: const Icon(Icons.logout_rounded,
                                color: Colors.white60),
                            tooltip: 'Đăng xuất',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Thống kê tổng quan ───────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E1645), Color(0xFF131629)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.analytics_rounded,
                                    color: Color(0xFF6C63FF), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Tổng thành tích tích lũy',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatColumn(
                                  label: 'Quãng đường',
                                  value: '${_totalDistance.toStringAsFixed(1)} km',
                                  iconColor: const Color(0xFF00E5A0),
                                ),
                                Container(
                                  height: 36,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                _StatColumn(
                                  label: 'Calories',
                                  value: '$_totalCalories kcal',
                                  iconColor: const Color(0xFFFF6B6B),
                                ),
                                Container(
                                  height: 36,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                _StatColumn(
                                  label: 'Buổi chạy',
                                  value: '${_runs.length}',
                                  iconColor: const Color(0xFFFFA726),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Header Lịch sử chạy ──────────────────────────
                      Row(
                        children: [
                          const Text(
                            'Lịch sử chạy & đi bộ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _showAddRunDialog,
                            icon: const Icon(Icons.add_circle_outline,
                                color: Color(0xFF00E5A0), size: 16),
                            label: const Text(
                              'Thêm mới',
                              style: TextStyle(
                                color: Color(0xFF00E5A0),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Danh sách lịch sử ────────────────────────────
                      if (_runs.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: const Center(
                            child: Text(
                              'Chưa có lịch sử chạy nào',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _runs.length,
                          itemBuilder: (context, index) {
                            final item = _runs[index];
                            final dist = (item['distance'] as num?)?.toDouble() ?? 0.0;
                            final cal = item['calories'] ?? 0;
                            final duration = item['duration'] ?? '';
                            final dateStr = _formatDate(item['created_at'] ?? '');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131629),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.directions_run_rounded,
                                      color: Color(0xFF6C63FF),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? 'Buổi chạy',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          dateStr,
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _TagBadge(
                                              icon: Icons.timer_outlined,
                                              text: duration,
                                            ),
                                            const SizedBox(width: 8),
                                            _TagBadge(
                                              icon: Icons.local_fire_department_rounded,
                                              text: '$cal kcal',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${dist.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFF00E5A0),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'km',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color iconColor;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: iconColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TagBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 12),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

