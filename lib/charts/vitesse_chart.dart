import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'base_drone_chart.dart';

class VitesseChart extends StatelessWidget {
  const VitesseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseDroneChart(
      unit: "km/h",
      barColor: Colors.blueAccent,
      areaColor: Color(0x33448AFF),
      spots: [
        FlSpot(0, 2),
        FlSpot(1, 3),
        FlSpot(2, 3.5),
        FlSpot(3, 4.5),
        FlSpot(4, 4),
      ],
    );
  }
}
