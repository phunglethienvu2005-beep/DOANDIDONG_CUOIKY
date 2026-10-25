import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/speed_service.dart';

class SpeedScreen extends StatefulWidget {
  const SpeedScreen({super.key});

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {

  final SpeedService speedService = SpeedService();

  double speed = 0;

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();

    startTracking();
  }

  Future<void> startTracking() async {

    bool allowed = await speedService.requestPermission();

    if (!allowed) return;

    positionStream =
        speedService.getPositionStream().listen((Position position) {

          setState(() {

            speed = position.speed * 3.6;

          });
        });
  }

  @override
  void dispose() {

    positionStream?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Tracking"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.speed,
              size: 100,
            ),

            const SizedBox(height: 20),

            Text(
              "${speed.toStringAsFixed(2)} km/h",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}