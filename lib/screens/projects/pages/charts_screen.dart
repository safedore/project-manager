import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 10,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 30),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    switch (value.toInt()) {
                      case 0: return const Text("Mon");
                      case 1: return const Text("Tue");
                      case 2: return const Text("Wed");
                      case 3: return const Text("Thu");
                      case 4: return const Text("Fri");
                      case 5: return const Text("Sat");
                      case 6: return const Text("Sun");
                      default: return const Text("");
                    }
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: const [
                  FlSpot(0, 3),
                  FlSpot(1, 5),
                  FlSpot(2, 6),
                  FlSpot(3, 4),
                  FlSpot(4, 7),
                  FlSpot(5, 3),
                  FlSpot(6, 6),
                ],
                dotData: FlDotData(show: true),
                color: Colors.blue,
                barWidth: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
