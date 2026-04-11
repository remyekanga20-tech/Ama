import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_drone_chart.dart';

class PitchChart extends StatelessWidget {
  const PitchChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "°",
      barColor: Colors.amber,
      areaColor: Color(0x33FFC107),
      spots: [
        FlSpot(0, 2),
        FlSpot(1, 4),
        FlSpot(2, 1),
        FlSpot(3, 6),
        FlSpot(4, 3),
      ],
    );
  }
}
