import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String username;
  final String city;
  final double temperature;
  final int steps;
  final double speed;
  final int highScore;

  const DashboardScreen({
    super.key,
    required this.username,
    required this.city,
    required this.temperature,
    required this.steps,
    required this.speed,
    this.highScore = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Xin chào
            Text(
              "Xin chào, $username",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            /// Weather
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "🌤 Thời tiết",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(city, style: const TextStyle(fontSize: 22)),

                    Text(
                      "${temperature.toStringAsFixed(1)} °C",
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Steps
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_walk),
                title: const Text("Hôm nay"),
                subtitle: Text("Bước chân: $steps"),
              ),
            ),

            const SizedBox(height: 10),

            /// Speed
            Card(
              child: ListTile(
                leading: const Icon(Icons.speed),
                title: const Text("Tốc độ hiện tại"),
                subtitle: Text("${speed.toStringAsFixed(1)} km/h"),
              ),
            ),

            const SizedBox(height: 20),

            /// High Score
            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text("Mini Game"),
                subtitle: Text("Điểm cao nhất: $highScore"),
              ),
            ),

            const Spacer(),

            /// Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.home),
                  label: const Text("Home"),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: const Text("Leaderboard"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
