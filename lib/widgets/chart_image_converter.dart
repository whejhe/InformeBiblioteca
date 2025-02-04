// chart_image_converter.dart
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart'; // Importa material para WidgetsFlutterBinding
import 'package:informe_biblioteca/services/widgets/syncfusion_chart_widget.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.MemoryImage> getChartImage(BuildContext context, List<ChartSampleData> data) async {
  // Asegurarse de que el binding de Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Crear el widget del gráfico
  final chart = SyncfusionChartWidget(data: data);

  // Renderizar el widget en un contexto
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Tamaño del gráfico
  final size = Size(300, 200);

  // Configurar el pipeline de renderizado
  final pipelineOwner = PipelineOwner();
  final rootRenderObject = RenderView(
    configuration: ViewConfiguration(size: size, devicePixelRatio: 1.0),
    child: RenderPositionedBox(child: RenderRepaintBoundary()), view: null,
  );

  pipelineOwner.rootNode = rootRenderObject;
  final buildContext = BuildContextInflator(rootRenderObject).inflate(() => Directionality(
        textDirection: TextDirection.ltr,
        child: Container(width: size.width, height: size.height, child: chart),
      ));

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  // Capturar la imagen
  final boundary = buildContext.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return pw.MemoryImage(byteData!.buffer.asUint8List());
}