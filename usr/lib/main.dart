import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'data/nlp_module_data.dart';

void main() {
  runApp(const NLPModuleApp());
}

class NLPModuleApp extends StatelessWidget {
  const NLPModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modul NLP: Analisis Sentimen YouTube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8), // Professional Blue
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSerifTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TableOfContentsScreen(),
      },
    );
  }
}

class TableOfContentsScreen extends StatelessWidget {
  const TableOfContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul Ajar NLP'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Analisis Sentimen YouTube",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: moduleChapters.length,
        itemBuilder: (context, index) {
          final chapter = moduleChapters[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                chapter.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                chapter.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterDetailScreen(chapter: chapter),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChapterDetailScreen extends StatelessWidget {
  final Chapter chapter;

  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
      ),
      body: Markdown(
        data: chapter.content,
        selectable: true,
        padding: const EdgeInsets.all(16),
        styleSheet: MarkdownStyleSheet(
          h1: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          h2: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          h3: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          p: GoogleFonts.notoSerif(fontSize: 16, height: 1.6, color: Colors.black87),
          code: GoogleFonts.firaCode(
            backgroundColor: const Color(0xFFF0F0F0),
            color: const Color(0xFFD32F2F),
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFF282C34),
            borderRadius: BorderRadius.circular(8),
          ),
          codeblockPadding: const EdgeInsets.all(16),
          blockquote: const TextStyle(color: Colors.grey),
        ),
        onTapLink: (text, href, title) {
          // Handle link taps if necessary
        },
      ),
    );
  }
}
