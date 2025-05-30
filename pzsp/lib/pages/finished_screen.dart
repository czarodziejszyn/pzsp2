import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fl_chart/fl_chart.dart';
import 'package:pzsp/models/dance_video_selection.dart';
import 'package:pzsp/pages/camera_screen.dart';
import 'package:pzsp/pages/home_page.dart';

class FinishedScreen extends StatefulWidget {
  final DanceVideoSelection selection;
  final double startTime;
  final double endTime;
  final IO.Socket channel;

  const FinishedScreen({
    super.key,
    required this.selection,
    required this.startTime,
    required this.endTime,
    required this.channel,
  });

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  List<int> keypointStats = [];

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    widget.channel.emit('status', jsonEncode({'status': 'done'}));

    widget.channel.on('result', (data) {
      List<int> results = List<int>.from(data);

      setState(() {
        keypointStats = results;
      });

      widget.channel.off('result');
      widget.channel.dispose();
    });
  }

  void restartDance() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(
          selection: widget.selection,
          startTime: widget.startTime,
          endTime: widget.endTime,
        ),
      ),
    );
  }

  void endDance() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  Widget buildChart() {
    if (keypointStats.isEmpty) {
      return const CircularProgressIndicator();
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) => Text('T${value.toInt() + 1}'),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: keypointStats
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                .toList(),
            isCurved: true,
            barWidth: 4,
            color: Colors.black,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.6),
                  Colors.yellow.withOpacity(0.6),
                  Colors.red.withOpacity(0.6),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dance Statistics")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Dance Stats for "${widget.selection.title}"',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(child: Center(child: buildChart())),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: restartDance,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: endDance,
                  icon: const Icon(Icons.home),
                  label: const Text('End'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
