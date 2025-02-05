// services/pdf_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:informe_biblioteca/models/book.dart';

/// Clase principal para generar informes PDF.
///
/// Esta clase utiliza el paquete `pdf` para crear documentos PDF
/// que contienen información sobre libros prestados por un usuario.
class PdfService {
  /// Genera un informe PDF con los datos proporcionados.
  ///
  /// [userName]: El nombre del usuario que generará el informe.
  /// [books]: Una lista de libros prestados por el usuario.
  /// [context]: El contexto de Flutter necesario para mostrar mensajes de error.
  ///
  /// Este método crea un documento PDF con:
  /// - Un título.
  /// - Una imagen del logotipo de la biblioteca.
  /// - El nombre del usuario.
  /// - Una lista de libros prestados con sus fechas de devolución.
  /// - Un enlace a la web ficticia de la biblioteca.
  ///
  /// Si se ejecuta en dispositivos móviles, guarda el archivo PDF en la carpeta de descargas.
  /// Si se ejecuta en web, comparte el archivo PDF directamente.
  ///
  /// @throws Exception si no se pueden solicitar permisos de almacenamiento o si ocurre un error durante la generación.
  static Future<void> generateReport({
    required String userName,
    required List<Book> books,
    required BuildContext context,
    required Uint8List chartImageBytes,
  }) async {
    try {
      if (!kIsWeb) {
        if (!await Permission.storage.isGranted) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Permisos de almacenamiento denegados');
          }
        }
      }

      // Crear el documento PDF
      final pdf = pw.Document();
      final logo = await imageFromAssetBundle('assets/images/logo.png');

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
              // Gráfico
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(chartImageBytes),
                  width: 300,
                  height: 150,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.UrlLink(
                child: pw.Text('Visita nuestra web'),
                destination: 'https://www.bibliodam.com',
              ),
            ],
          ),
        ),
      );

      if (!kIsWeb) {
        final output = await getDownloadsDirectory();
        if (output == null) throw Exception('No se encontró el directorio');
        final file = File('${output.path}/informe.pdf');
        await file.writeAsBytes(await pdf.save());
        final openResult = await OpenFile.open(file.path);
        if (openResult.type != ResultType.done) {
          throw Exception('No se pudo abrir el archivo: ${openResult.message}');
        }
      } else {
        final bytes = await pdf.save();
        await Printing.sharePdf(bytes: bytes, filename: 'informe.pdf');
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

  /// Formatea una fecha [DateTime] en un string con formato "DD/MM/YYYY".
  ///
  /// @param date La fecha a formatear.
  /// @return Un string con la fecha formateada.
  static String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
