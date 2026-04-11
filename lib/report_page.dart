import 'package:flutter/material.dart';
import 'widgets/flight_companion.dart';
import 'models/flight_record.dart';
import 'services/flight_history_service.dart';
import 'services/excel_export_service.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Données de simulation basées sur les graphiques
    const List<double> vitesseData = [2, 3, 3.5, 4.5, 4];
    const List<double> accelZData = [1, 1.8, 2.5, 2, 3];

    // Calculs de Vitesse
    double vitesseMax = 4.5;
    double vitesseMoyenne =
    (vitesseData.reduce((a, b) => a + b) / vitesseData.length);

    // Calculs de Montée
    double monteeMax = 2.0; // Max diff in altitudeData per 5s

    // Analyse de Stabilité
    bool estStable = true;
    String phaseInstable = "Aucune (vol stable)";
    if (accelZData.any((v) => v > 2.8)) {
      estStable = false;
      phaseInstable = "Phase finale (T20s) : fortes vibrations détectées";
    }

    // --- Enregistrement du vol dans l'historique local ---
    final record = FlightRecord(
      id: "VOL-${DateTime.now().millisecondsSinceEpoch}",
      date: DateTime.now(),
      duree: const Duration(minutes: 10), // TODO: durée réelle du vol
      altitudeMax: 50.0, // TODO: altitude max réelle
      vitesseMax: vitesseMax,
    );
    FlightHistoryService.addFlightAndTrim(record);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rapport de Vol Automatique"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Statistiques de Performances"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStatCard(
                            "Vit. Moyenne",
                            "${vitesseMoyenne.toStringAsFixed(1)} km/h",
                            Icons.speed,
                          ),
                          _buildStatCard(
                            "Vit. Maximale",
                            "$vitesseMax km/h",
                            Icons.bolt,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStatCard(
                            "Montée Max",
                            "$monteeMax m/s",
                            Icons.trending_up,
                          ),
                          _buildStatCard(
                            "Stabilité",
                            estStable ? "Stable" : "Instable",
                            estStable
                                ? Icons.check_circle
                                : Icons.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                      _buildSectionTitle("Analyse Experte du Vol"),
                      const SizedBox(height: 10),
                      _buildAnalysisCard(
                        "Le vol présente un profil de vitesse progressif avec une accélération maîtrisée. "
                            "La vitesse moyenne de ${vitesseMoyenne.toStringAsFixed(1)} km/h indique un deplacement fluide. "
                            "Cependant, une legère instabilité a été detectée lors de la phase : $phaseInstable.\n\n"
                            "Recommandation : Vérifier l'équilibrage des hélices arrières suite aux vibrations en fin de mission.",
                      ),
                      const SizedBox(height: 20),
                      _buildQuestionSection("Questions Clés", [
                        "Vitesse Moyenne : ${vitesseMoyenne.toStringAsFixed(1)} km/h",
                        "Vitesse Maximale : $vitesseMax km/h",
                        "Vol Stable ? : ${estStable ? "Oui, globalement" : "Non, instabilité détectée"}",
                        "Phase la plus instable : $phaseInstable",
                        "Vitesse de montée maximale : $monteeMax m/s",
                      ]),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final file =
                      await ExcelExportService.exportFlightSummary(record);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Rapport Excel enregistré : ${file.path}",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text("Télécharger le rapport Excel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 250,
            right: 16,
            child: FlightCompanion(
              message: estStable
                  ? "Quel beau vol ! Rapport termine."
                  : "Attention Capitaine, l'instabilite finale etait critique.",
              isWarning: !estStable,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.pink, size: 30),
              const SizedBox(height: 10),
              Text(
                label,
                style:
                const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuestionSection(String title, List<String> answers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...answers.map(
              (answer) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, color: Colors.pink),
                Expanded(
                  child: Text(
                    answer,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}