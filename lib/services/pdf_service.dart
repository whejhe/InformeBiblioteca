import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../models/book.dart';
import '../widgets/chart_widget.dart';

class PdfService {
  static Future<void> generateReport({
    required String userName,
    required List<Book> books,
    required BuildContext context,
  }) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permisos de almacenamiento denegados');
      }

      final pdf = pw.Document();
      final logo = await imageFromAssetBundle(
          'assets/logo.png'); // Agrega tu logo en assets

      // Crear gráfico como imagen
      final chartImage = await ChartWidget.getChartImage();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0,
                  child: pw.Text('Informe de Préstamos',
                      style: pw.TextStyle(fontSize: 24))),
              pw.Image(logo, width: 100, height: 100),
              pw.SizedBox(height: 20),
              pw.Text('Usuario: $userName',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text('Libros prestados:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...books.map((book) => pw.Text(
                  '${book.id}: ${book.title} - Devolución: ${_formatDate(book.returnDate)}')),
              pw.SizedBox(height: 20),
              pw.Image(chartImage), // Gráfico
              pw.UrlLink(
                child: pw.Text('Visita nuestra web'),
                destination: 'https://www.bibliojuan.com',
              ),
            ],
          ),
        ),
      );

      // Guardar y abrir el PDF
      final output = await getDownloadsDirectory();
      if (output == null) throw Exception('No se encontró el directorio');
      final file = File('${output.path}/informe.pdf');
      await file.writeAsBytes(await pdf.save());
      final openResult = await OpenFile.open(file.path);
      if (openResult.type != ResultType.done) {
        throw Exception('No se pudo abrir el archivo: ${openResult.message}');
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
