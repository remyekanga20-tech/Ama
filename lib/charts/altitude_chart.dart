import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'base_drone_chart.dart';

class AltitudeChart extends StatelessWidget {
  const AltitudeChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "m",
      spots: [
        FlSpot(0, 1),
        FlSpot(1, 2),
        FlSpot(2, 4),
        FlSpot(3, 3),
        FlSpot(4, 5),
      ],
    );
  }
}
