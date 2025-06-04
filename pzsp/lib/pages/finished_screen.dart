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

  double getAverageScore() {
    if (keypointStats.isEmpty) return 0;
    return keypointStats.reduce((a, b) => a + b) / keypointStats.length;
  }

  String getScoreTitle(double avg) {
    if (avg < 30) return "First Steps";
    if (avg < 50) return "Dance Floor Rookie";
    if (avg < 75) return "Dancing Hero";
    if (avg < 90) return "Master of the Floor";
    return "Virtuoso of Movement";
  }

  Future<void> fetchStatistics() async {
    widget.channel.emit('status', jsonEncode({'status': 'done'}));

    widget.channel.on('result', (data) {
      List<int> results = List<int>.from(data);

      setState(() {
        keypointStats = results;
        // keypointStats = [80, 82, 54, 32, 56, 80, 90, 72, 86, 82];
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

  Widget buildChart(double avg) {
    if (keypointStats.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(strokeWidth: 5),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles:
                SideTitles(showTitles: true, interval: 20, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) =>
                  Text('T${value.toInt() + 1}',),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            color: const Color.fromARGB(255, 58, 92, 153),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 76, 175, 80).withAlpha(60),
                  const Color.fromARGB(255, 255, 235, 59).withAlpha(60),
                  const Color.fromARGB(255, 244, 67, 54).withAlpha(60),
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: List.generate(
                keypointStats.length, (i) => FlSpot(i.toDouble(), avg)),
            isCurved: false,
            barWidth: 2,
            color: Colors.orange,
            dotData: const FlDotData(show: false),
            dashArray: [6, 3],
          ),
        ],
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: avg,
            color: Colors.orange,
            strokeWidth: 2,
            dashArray: [6, 3],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(bottom: 20),
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
              labelResolver: (_) => 'Avg: ${avg.toString()}%',
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avg = (getAverageScore() * 10).round() / 10;
    final danceRank = getScoreTitle(avg);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 58, 92, 153),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Dance Stats for',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                '"${widget.selection.title}"',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 58, 92, 153)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: buildChart(avg),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Average Score: ${avg.toString()}%',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'Your Dance Rank: $danceRank',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: restartDance,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Restart',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 58, 92, 153),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: endDance,
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text('Home',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 244, 67, 54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
