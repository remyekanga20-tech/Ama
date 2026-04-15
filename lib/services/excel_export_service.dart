import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

import '../models/flight_record.dart';

class ExcelExportService {
  static Future<File> exportFlightSummary(FlightRecord record) async {
    final workbook = xls.Workbook();

    final summary = workbook.worksheets[0];
    summary.name = 'Résumé du vol';

    summary.getRangeByName('A1').setText('ID du vol');
    summary.getRangeByName('B1').setText(record.id);

    summary.getRangeByName('A2').setText('Date');
    summary.getRangeByName('B2').setText(record.date.toIso8601String());

    summary.getRangeByName('A3').setText('Durée (s)');
    summary.getRangeByName('B3').setNumber(record.duree.inSeconds.toDouble());

    summary.getRangeByName('A4').setText('Altitude max (m)');
    summary.getRangeByName('B4').setNumber(record.altitudeMax);

    summary.getRangeByName('A5').setText('Vitesse max (m/s)');
    summary.getRangeByName('B5').setNumber(record.vitesseMax);

    final dataSheet = workbook.worksheets.addWithName('Données exemple');
    dataSheet.getRangeByName('A1').setText('Temps (s)');
    dataSheet.getRangeByName('B1').setText('Altitude (m)');
    dataSheet.getRangeByName('C1').setText('Vitesse (m/s)');

    final List<int> times = [0, 5, 10, 15, 20];
    final List<double> altitudes = [
      0,
      record.altitudeMax * 0.4,
      record.altitudeMax * 0.7,
      record.altitudeMax * 0.9,
      record.altitudeMax,
    ];
    final List<double> speeds = [
      record.vitesseMax * 0.3,
      record.vitesseMax * 0.6,
      record.vitesseMax,
      record.vitesseMax * 0.8,
      record.vitesseMax * 0.5,
    ];

    for (int i = 0; i < times.length; i++) {
      final row = i + 2;
      dataSheet.getRangeByIndex(row, 1).setNumber(times[i].toDouble());
      dataSheet.getRangeByIndex(row, 2).setNumber(altitudes[i]);
      dataSheet.getRangeByIndex(row, 3).setNumber(speeds[i]);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${record.id}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}