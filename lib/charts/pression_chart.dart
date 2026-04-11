import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_drone_chart.dart';

class PressionChart extends StatelessWidget {
  const PressionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "hPa",
      barColor: Colors.purple,
      areaColor: Color(0x339C27B0),
      spots: [
        FlSpot(0, 1012),
        FlSpot(1, 1011),
        FlSpot(2, 1010),
        FlSpot(3, 1009),
        FlSpot(4, 1008),
      ],
    );
  }
}
