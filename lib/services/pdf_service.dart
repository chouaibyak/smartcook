import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/ingredient_model.dart';

class PdfService {
  static Future<void> exportShoppingList({
    required List<Ingredient> missingIngredients,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "SmartCook Shopping List",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Text(
                "Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              ),

              pw.SizedBox(height: 24),

              pw.Text(
                "Missing Ingredients",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              ...missingIngredients.map(
                (item) => pw.Bullet(
                  text: "${item.nom} - ${item.quantite} ${item.unite}",
                ),
              ),

              
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}