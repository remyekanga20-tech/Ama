import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'base_drone_chart.dart';

class RollChart extends StatelessWidget {
  const RollChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "°",
      barColor: Colors.teal,
      areaColor: Color(0x33009688),
      spots: [
        FlSpot(0, 0),
        FlSpot(1, 5),
        FlSpot(2, -2),
        FlSpot(3, 3),
        FlSpot(4, 1),
      ],
    );
  }
}
