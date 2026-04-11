import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_drone_chart.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "°C",
      barColor: Colors.redAccent,
      areaColor: Color(0x33FF5252),
      spots: [
        FlSpot(0, 20),
        FlSpot(1, 21),
        FlSpot(2, 23),
        FlSpot(3, 24),
        FlSpot(4, 22),
      ],
    );
  }
}
