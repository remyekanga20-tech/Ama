import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'charts/base_drone_chart.dart';
import 'services/flight_brain.dart';
import 'services/supabase_service.dart';
import 'widgets/flight_companion.dart';

class GraphicPage extends StatefulWidget {
  const GraphicPage({super.key});

  @override
  State<GraphicPage> createState() => _GraphicPageState();
}

class _GraphicPageState extends State<GraphicPage> {
  String selectedParam = "altitude";

  DateTime? _lastUpdateTime;
  Duration dataFreshness = const Duration(seconds: 2);

  final Map<String, String> analyses = {
    "altitude":
    "Analyse de la montée et de la descente. Elle permet de vérifier l'évolution de l'altitude au cours du vol.",
    "vitesse":
    "Analyse de la performance de vol : accélération, stabilisation et variations de vitesse.",
    "accel_z":
    "Analyse de l'accélération verticale pour détecter les turbulences et la stabilité du drone.",
    "temperature":
    "Analyse de l'influence de l'atmosphère sur les composants et les performances.",
    "pression":
    "Mesure de la pression atmosphérique utilisée pour estimer les conditions de vol.",
    "roll":
    "Stabilité latérale : inclinaison gauche/droite du drone en degrés.",
    "pitch":
    "Stabilité longitudinale : inclinaison avant/arrière du drone en degrés.",
    "yaw":
    "Direction du nez du drone en degrés.",
  };

  Widget _getSelectedChart(List<Map<String, dynamic>> telemetryData) {
    if (telemetryData.isEmpty) {
      return const Center(
        child: Text("En attente de données spatio-temporelles..."),
      );
    }

    List<FlSpot> spots = [];
    int startIdx = telemetryData.length > 20 ? telemetryData.length - 20 : 0;
    List<Map<String, dynamic>> recentData = telemetryData.sublist(startIdx);

    for (int i = 0; i < recentData.length; i++) {
      double val =
          double.tryParse(recentData[i][selectedParam]?.toString() ?? '0') ??
              0.0;
      spots.add(FlSpot(i.toDouble(), val));
    }

    String unit = "";
    switch (selectedParam) {
      case "altitude":
        unit = "m";
        break;
      case "vitesse":
        unit = "m/s";
        break;
      case "accel_z":
        unit = "g";
        break;
      case "temperature":
        unit = "°C";
        break;
      case "pression":
        unit = "hPa";
        break;
      default:
        unit = "°"; // roll, pitch, yaw
    }

    return BaseDroneChart(unit: unit, spots: spots);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Représentation des données"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SupabaseService.getTelemetryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Erreur de flux de données: ${snapshot.error}"),
            );
          }

          final List<Map<String, dynamic>> data = snapshot.data ?? [];
          final Map<String, dynamic> lastData =
          data.isNotEmpty ? data.last : {};

          if (data.isNotEmpty) {
            _lastUpdateTime = DateTime.now();
          }

          final double currentAltitude =
          parseDouble(lastData["altitude"]);
          final double currentVitesse =
          parseDouble(lastData["vitesse"]);
          final double currentAccelZ =
          parseDouble(lastData["accel_z"]);

          final String expertAdvice = FlightBrain.getExpertAdvice(
            altitude: currentAltitude,
            vitesse: currentVitesse,
            accelZ: currentAccelZ,
            temperature: parseDouble(lastData["temperature"]),
            roll: parseDouble(lastData["roll"]),
          );

          final bool isWarning = expertAdvice.contains("Attention") ||
              expertAdvice.contains("Surchauffe");

          final String statusLabel = isWarning ? "Alerte" : "Nominal";
          final Color statusColor =
          isWarning ? Colors.orange : Colors.green;

          bool isSignalFresh = false;
          if (_lastUpdateTime != null) {
            final diff = DateTime.now().difference(_lastUpdateTime!);
            isSignalFresh = diff <= dataFreshness;
          }

          return Stack(
            children: [
              Column(
                children: [
                  // ---------- Bandeau KPI vol ----------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.airplanemode_active,
                              color: Colors.pink.shade400,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Résumé du vol",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Alt: ${currentAltitude.toStringAsFixed(1)} m  ·  Vit: ${currentVitesse.toStringAsFixed(1)} m/s",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.wifi_tethering,
                              color: isSignalFresh ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isWarning
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle,
                                    color: statusColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ---------- Sélecteur de paramètre ----------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timeline, color: Colors.pink),
                          const SizedBox(width: 12),
                          const Text(
                            "Paramètre : ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedParam,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: analyses.keys.map((param) {
                                  return DropdownMenuItem<String>(
                                    value: param,
                                    child: Text(param.toUpperCase()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => selectedParam = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---------- Carte graphique ----------
                  Expanded(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Courbe : ${selectedParam.toUpperCase()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _getSelectedChart(data),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ---------- Carte analyse + mini KPI ----------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Card(
                      color: Colors.pinkAccent[100],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Analyse : ${selectedParam.toUpperCase()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (data.isNotEmpty) _buildParamKpiRow(data),
                            if (data.isNotEmpty) const SizedBox(height: 8),
                            Text(
                              analyses[selectedParam] ?? "",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ---------- Compagnon de vol ----------
              Positioned(
                bottom: 140,
                right: 16,
                child: FlightCompanion(
                  message: expertAdvice,
                  isWarning: isWarning,
                  flightContext: lastData,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Construit les mini KPI (actuelle / min / max) pour le paramètre sélectionné
  Widget _buildParamKpiRow(List<Map<String, dynamic>> data) {
    final values = data
        .map((e) => parseDouble(e[selectedParam]))
        .where((v) => v != 0)
        .toList();
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    final current = values.last;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    String unit;
    switch (selectedParam) {
      case "altitude":
        unit = "m";
        break;
      case "vitesse":
        unit = "m/s";
        break;
      case "accel_z":
        unit = "g";
        break;
      case "temperature":
        unit = "°C";
        break;
      case "pression":
        unit = "hPa";
        break;
      default:
        unit = "°";
    }

    TextStyle labelStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 12,
    );
    TextStyle valueStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Actuelle", style: labelStyle),
            Text(
              "${current.toStringAsFixed(1)} $unit",
              style: valueStyle,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Min", style: labelStyle),
            Text(
              "${min.toStringAsFixed(1)} $unit",
              style: valueStyle,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Max", style: labelStyle),
            Text(
              "${max.toStringAsFixed(1)} $unit",
              style: valueStyle,
            ),
          ],
        ),
      ],
    );
  }

  double parseDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0.0;
  }

  String _getCompanionMessage(Map<String, dynamic> lastData) {
    if (lastData.isEmpty) return "J'attends le démarrage des moteurs...";

    return FlightBrain.getExpertAdvice(
      altitude: parseDouble(lastData["altitude"]),
      vitesse: parseDouble(lastData["vitesse"]),
      accelZ: parseDouble(lastData["accel_z"]),
      temperature: parseDouble(lastData["temperature"]),
      roll: parseDouble(lastData["roll"]),
    );
  }
}