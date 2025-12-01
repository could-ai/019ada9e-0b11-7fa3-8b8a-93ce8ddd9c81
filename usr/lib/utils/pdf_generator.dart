import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/nlp_module_data.dart';

class PdfGenerator {
  static Future<void> generateAndPrint() async {
    final doc = pw.Document();
    
    // Use standard fonts to ensure reliability without internet if needed, 
    // or use PdfGoogleFonts if you want specific styling. 
    // Here we use standard fonts for speed and reliability in this demo.
    final font = await PdfGoogleFonts.notoSerifRegular();
    final fontBold = await PdfGoogleFonts.notoSerifBold();
    final fontMono = await PdfGoogleFonts.firaCodeRegular();

    // Cover Page
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('MODUL AJAR', style: pw.TextStyle(font: fontBold, fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text(
                'NATURAL LANGUAGE PROCESSING', 
                style: pw.TextStyle(font: fontBold, fontSize: 30, fontWeight: pw.FontWeight.bold), 
                textAlign: pw.TextAlign.center
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Analisis Sentimen YouTube', 
                style: pw.TextStyle(font: font, fontSize: 20)
              ),
              pw.SizedBox(height: 50),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Panduan Lengkap: Teori & Implementasi Python', 
                style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)
              ),
            ],
          ),
        ),
      ),
    );

    // Chapters
    for (var chapter in moduleChapters) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(chapter.title, style: pw.TextStyle(font: fontBold, fontSize: 24)),
            ),
            pw.SizedBox(height: 20),
            ..._parseMarkdown(chapter.content, font, fontBold, fontMono),
          ],
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Modul_NLP_Analisis_Sentimen.pdf',
    );
  }

  static List<pw.Widget> _parseMarkdown(String content, pw.Font font, pw.Font fontBold, pw.Font fontMono) {
    final lines = content.split('\n');
    final widgets = <pw.Widget>[];
    
    bool inCodeBlock = false;
    String codeBuffer = "";

    for (var line in lines) {
      // Handle Code Blocks
      if (line.trim().startsWith('```')) {
        if (inCodeBlock) {
          // End of code block
          widgets.add(
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.symmetric(vertical: 10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                codeBuffer.trim(), 
                style: pw.TextStyle(font: fontMono, fontSize: 10, color: PdfColors.blue900)
              ),
            ),
          );
          codeBuffer = "";
          inCodeBlock = false;
        } else {
          // Start of code block
          inCodeBlock = true;
        }
        continue;
      }

      if (inCodeBlock) {
        codeBuffer += "$line\n";
        continue;
      }

      // Handle Headings
      if (line.startsWith('# ')) {
        // Usually redundant with chapter title, but let's keep it if it's distinct
        // We skip it if it's very similar to the chapter title we just added in the header
        // But for safety, let's render it as a sub-header style
        widgets.add(pw.SizedBox(height: 15));
        widgets.add(pw.Text(line.replaceAll('# ', ''), style: pw.TextStyle(font: fontBold, fontSize: 20)));
        widgets.add(pw.Divider(thickness: 0.5, color: PdfColors.grey400));
        widgets.add(pw.SizedBox(height: 10));
      } else if (line.startsWith('## ')) {
         widgets.add(pw.SizedBox(height: 15));
         widgets.add(pw.Text(line.replaceAll('## ', ''), style: pw.TextStyle(font: fontBold, fontSize: 16)));
         widgets.add(pw.SizedBox(height: 5));
      } else if (line.startsWith('### ')) {
         widgets.add(pw.SizedBox(height: 10));
         widgets.add(pw.Text(line.replaceAll('### ', ''), style: pw.TextStyle(font: fontBold, fontSize: 14)));
         widgets.add(pw.SizedBox(height: 5));
      } else if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 5));
      } else {
        // Normal text
        // Basic bold handling for **text**
        // We will just strip the ** for now to keep it clean, or use a simple regex to bold it if possible.
        // pw.RichText is needed for mixed styles. Let's do a simple RichText parser for **bold**.
        
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: _parseRichText(line, font, fontBold),
          )
        );
      }
    }
    return widgets;
  }

  static pw.Widget _parseRichText(String text, pw.Font font, pw.Font fontBold) {
    final List<pw.InlineSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Text before bold
      if (match.start > lastIndex) {
        spans.add(pw.TextSpan(
          text: text.substring(lastIndex, match.start),
          style: pw.TextStyle(font: font, fontSize: 12),
        ));
      }
      
      // Bold text
      spans.add(pw.TextSpan(
        text: match.group(1),
        style: pw.TextStyle(font: fontBold, fontSize: 12),
      ));
      
      lastIndex = match.end;
    }

    // Remaining text
    if (lastIndex < text.length) {
      spans.add(pw.TextSpan(
        text: text.substring(lastIndex),
        style: pw.TextStyle(font: font, fontSize: 12),
      ));
    }

    return pw.RichText(
      text: pw.TextSpan(children: spans),
      textAlign: pw.TextAlign.justify,
    );
  }
}
