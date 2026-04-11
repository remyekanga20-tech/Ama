import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_drone_chart.dart';

class AccelZChart extends StatelessWidget {
  const AccelZChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "m/s²",
      barColor: Colors.green,
      areaColor: Color(0x334CAF50),
      spots: [
        FlSpot(0, 1),
        FlSpot(1, 1.8),
        FlSpot(2, 2.5),
        FlSpot(3, 2),
        FlSpot(4, 3),
      ],
    );
  }
}
