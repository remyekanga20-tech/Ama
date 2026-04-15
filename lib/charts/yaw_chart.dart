import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'base_drone_chart.dart';

class YawChart extends StatelessWidget {
  const YawChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "°",
      barColor: Colors.indigo,
      areaColor: Color(0x333F51B5),
      spots: [
        FlSpot(0, 10),
        FlSpot(1, 20),
        FlSpot(2, 35),
        FlSpot(3, 30),
        FlSpot(4, 45),
      ],
    );
  }
}
