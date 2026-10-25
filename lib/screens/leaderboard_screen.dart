import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> scores = [];
  bool _loading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    loadScores();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> loadScores() async {
    final data = await DatabaseHelper.instance.getTopScores();
    if (!mounted) return;
    setState(() {
      scores = data;
      _loading = false;
    });
    _animController.forward();
  }

  String formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFD700); // gold
      case 1:
        return const Color(0xFFC0C0C0); // silver
      case 2:
        return const Color(0xFFCD7F32); // bronze
      default:
        return Colors.white30;
    }
  }

  IconData _rankIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events_rounded;
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.emoji_events_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bảng xếp hạng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Top Mini Game',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() => _loading = true);
                      _animController.reset();
                      loadScores();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131629),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : scores.isEmpty
                      ? _buildEmptyState()
                      : FadeTransition(
                          opacity: _fadeAnim,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            itemCount: scores.length,
                            itemBuilder: (context, index) {
                              return _buildScoreCard(index, scores[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131629),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.leaderboard_rounded,
              color: Colors.white24,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có điểm nào',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hãy chơi Mini Game để ghi điểm!',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int index, Map<String, dynamic> item) {
    final rankColor = _rankColor(index);
    final isTopThree = index < 3;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 60),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131629),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTopThree
              ? rankColor.withOpacity(0.35)
              : Colors.white.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: rankColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: rankColor.withOpacity(isTopThree ? 0.5 : 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isTopThree
                    ? Icon(_rankIcon(index), color: rankColor, size: 20)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['username'] ?? '--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.whatshot_rounded,
                          color: Colors.orange, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Wave ${item['wave'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white24, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(item['created_at'] ?? ''),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTopThree
                      ? [
                          rankColor.withOpacity(0.25),
                          rankColor.withOpacity(0.1)
                        ]
                      : [
                          const Color(0xFF6C63FF).withOpacity(0.15),
                          const Color(0xFF6C63FF).withOpacity(0.05)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item['score'] ?? 0}',
                style: TextStyle(
                  color: isTopThree ? rankColor : const Color(0xFF6C63FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}