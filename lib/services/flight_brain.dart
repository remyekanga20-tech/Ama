class FlightBrain {
  // Petite mémoire interne pour lisser les valeurs
  static final List<double> _recentTemps = [];
  static final List<double> _recentAccelZ = [];
  static final int _windowSize = 5; // taille de la fenêtre de lissage

  // Compteurs pour "danger persistant"
  static int _dangerTempCount = 0;
  static int _dangerAccelCount = 0;
  static const int _dangerThresholdSamples = 3; // ex: 3 échantillons consécutifs

  static double _smooth(List<double> buffer, double newValue) {
    buffer.add(newValue);
    if (buffer.length > _windowSize) {
      buffer.removeAt(0);
    }
    double sum = 0;
    for (final v in buffer) {
      sum += v;
    }
    return sum / buffer.length;
  }

  /// Analyse les paramètres de vol et retourne un conseil intelligent.
  static String getExpertAdvice({
    required double altitude,
    required double vitesse,
    required double accelZ,
    required double temperature,
    required double roll,
  }) {
    // Lissage des valeurs sensibles
    final double smoothTemp = _smooth(_recentTemps, temperature);
    final double smoothAccelZ = _smooth(_recentAccelZ, accelZ);

    // Mise à jour des compteurs de "danger persistant"
    if (smoothTemp > 24.0) {
      _dangerTempCount++;
    } else {
      _dangerTempCount = 0;
    }

    if (smoothAccelZ > 2.5) {
      _dangerAccelCount++;
    } else {
      _dangerAccelCount = 0;
    }

    final bool tempDangerPersistent =
        _dangerTempCount >= _dangerThresholdSamples;
    final bool accelDangerPersistent =
        _dangerAccelCount >= _dangerThresholdSamples;

    // Règle 1 : Sécurité structurelle (Vitesse vs Accel) avec persistance
    if (vitesse > 4.0 && accelDangerPersistent) {
      return "Risque de fatigue structurelle ! Reduisez la vitesse en zone de turbulences.";
    }

    // Règle 2 : Stabilité de l'assiette
    if (roll.abs() > 10.0) {
      return "Inclinaison excessive detectee. Verifiez l'equilibrage du drone.";
    }

    // Règle 3 : Performance thermique (lissée + persistance)
    if (smoothTemp > 23.0 && tempDangerPersistent) {
      return "Temperature en hausse de maniere persistante. Surveillez le refroidissement des ESC.";
    }

    // Règle 5 : Batterie (Simulation)
    if (vitesse > 3.0 && altitude > 4.5) {
      return "Consommation energie elevee en haute altitude. Surveillez le temps de vol restant.";
    }

    // Règle 6 : Trajectoire rectiligne
    if (roll.abs() < 1.0 && vitesse > 3.0) {
      return "Trajectoire parfaitement rectiligne. Stabilite aerodynamique optimale.";
    }

    // Règle 7 : Temperature vs Vitesse (lissée + persistance forte)
    if (tempDangerPersistent && vitesse > 4.0) {
      return "Surchauffe legere persistante a haute vitesse. Envisagez un palier de refroidissement.";
    }

    // Règle par défaut
    return "Vol nominal. Parametres de telemetrie dans la plage de securite.";
  }

  /// Retourne un commentaire de fin de vol pour le rapport.
  static String generateFinalVerdict(bool estStable, double vitesseMax) {
    if (estStable && vitesseMax < 5.0) {
      return "Mission Reussie. Profil de vol fluide et securise. Aucune maintenance preventive requise.";
    } else if (!estStable) {
      return "Attention : Instabilites detectees. Une inspection des moteurs et des helices est fortement recommandee avant le prochain decollage.";
    } else {
      return "Performances elevees. Verifiez l'integrite thermique apres ce vol a haute vitesse.";
    }
  }
}