import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/flight_record.dart';

class FlightHistoryService {
  static const String _fileName = "flight_history.json";

  // Récupère le fichier dans le dossier documents de l'app
  static Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory(); // [web:57][web:67]
    final path = "${dir.path}/$_fileName";
    return File(path);
  }

  // Charge tous les vols enregistrés (liste vide si rien encore)
  static Future<List<FlightRecord>> loadHistory() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }
      final content = await file.readAsString();
      if (content.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList
          .map((e) => FlightRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Ajoute un vol et sauvegarde
  static Future<void> addFlight(FlightRecord record) async {
    final history = await loadHistory();
    history.add(record);

    final file = await _getHistoryFile();
    final jsonList = history.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList)); // [web:57][web:69]
  }

  // Optionnel: limiter à N vols récents
  static Future<void> addFlightAndTrim(FlightRecord record,
      {int maxRecords = 20}) async {
    final history = await loadHistory();
    history.add(record);
    while (history.length > maxRecords) {
      history.removeAt(0);
    }

    final file = await _getHistoryFile();
    final jsonList = history.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}