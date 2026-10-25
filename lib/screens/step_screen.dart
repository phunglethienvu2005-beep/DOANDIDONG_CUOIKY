import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepScreen extends StatefulWidget {
  const StepScreen({super.key});

  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  late Stream<StepCount> _stepCountStream;

  int steps = 0;
  String status = "Unknown";

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    await Permission.activityRecognition.request();

    initPedometer();
  }

  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(
      onStepCount,
      onError: onStepError,
    );
  }

  void onStepCount(StepCount event) {
    setState(() {
      steps = event.steps;
    });
  }

  void onStepError(error) {
    setState(() {
      status = "Step Count not available";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step Counter"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.directions_walk,
              size: 100,
            ),

            const SizedBox(height: 20),

            Text(
              "$steps",
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Steps",
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}