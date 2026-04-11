import 'package:google_generative_ai/google_generative_ai.dart';

class AiAnalysisService {
  // Ta clé Gemini (évite de la pousser sur un repo public)
  static const String _apiKey = 'AIzaSyAUwM-1Np90F2iscL7_CBcN8HObfBW1yj8';

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.0-pro',
    apiKey: _apiKey,
  );

  /// Conseil rapide pour le flight companion, basé sur le dernier contexte de vol
  static Future<String> quickAdviceFromContext({
    required Map<String, dynamic> contextData,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception("Clé Gemini manquante.");
    }

    final alt = _toDouble(contextData['altitude']);
    final vit = _toDouble(contextData['vitesse']);
    final accelZ = _toDouble(contextData['accel_z']);
    final temp = _toDouble(contextData['temperature']);
    final roll = _toDouble(contextData['roll']);
    final pitch = _toDouble(contextData['pitch']);
    final yaw = _toDouble(contextData['yaw']);

    final prompt = StringBuffer()
      ..writeln(
          "Tu es un instructeur de pilotage. Donne un conseil court (1 ou 2 phrases) au pilote en te basant sur ces données de vol.")
      ..writeln("Données actuelles :")
      ..writeln("- altitude (m) = $alt")
      ..writeln("- vitesse (m/s) = $vit")
      ..writeln("- accel_z = $accelZ")
      ..writeln("- temperature (°C) = $temp")
      ..writeln("- roll (deg) = $roll")
      ..writeln("- pitch (deg) = $pitch")
      ..writeln("- yaw (deg) = $yaw")
      ..writeln(
          "Indique ce qu'il doit surveiller ou ajuster maintenant. Réponds en français, de façon pratique.");

    final response =
    await _model.generateContent([Content.text(prompt.toString())]);
    final text = response.text ?? "";

    if (text.trim().isEmpty) {
      return "Les paramètres semblent corrects. Continue avec des manœuvres progressives et surveille les variations brusques.";
    }

    return text.trim();
  }

  static double _toDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0.0;
}