import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AlHirfaApp());
}

class AlHirfaApp extends StatelessWidget {
  const AlHirfaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AL-HIRFA | الحرفة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF0F0F0F),
        ),
        fontFamily: GoogleFonts.cairo().fontFamily,
      ),
      home: const AlHirfaHome(),
    );
  }
}

class AlHirfaHome extends StatefulWidget {
  const AlHirfaHome({super.key});

  @override
  State<AlHirfaHome> createState() => _AlHirfaHomeState();
}

class _AlHirfaHomeState extends State<AlHirfaHome> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _screens = [
    {'label': 'الرئيسية', 'icon': Icons.home_outlined,                  'activeIcon': Icons.home,                   'asset': 'screen_4.html'},
    {'label': 'الأصناف',  'icon': Icons.grid_view_outlined,             'activeIcon': Icons.grid_view,              'asset': 'screen_10.html'},
    {'label': 'المحفظة',  'icon': Icons.account_balance_wallet_outlined, 'activeIcon': Icons.account_balance_wallet, 'asset': 'screen_5.html'},
    {'label': 'الحرفي',   'icon': Icons.gavel_outlined,                 'activeIcon': Icons.gavel,                  'asset': 'screen_3.html'},
    {'label': 'الطلبات',  'icon': Icons.shopping_bag_outlined,          'activeIcon': Icons.shopping_bag,           'asset': 'screen_2.html'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: HtmlScreen(assetPath: _screens[_currentIndex]['asset']),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1208),
          border: Border(
            top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.cairo().fontFamily),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: GoogleFonts.cairo().fontFamily),
          items: _screens.map((s) => BottomNavigationBarItem(
            icon: Icon(s['icon'] as IconData),
            activeIcon: Icon(s['activeIcon'] as IconData),
            label: s['label'] as String,
          )).toList(),
        ),
      ),
    );
  }
}

class HtmlScreen extends StatefulWidget {
  final String assetPath;
  const HtmlScreen({super.key, required this.assetPath});

  @override
  State<HtmlScreen> createState() => _HtmlScreenState();
}

class _HtmlScreenState extends State<HtmlScreen> {
  InAppWebViewController? _controller;
  bool _loading = true;
  String _htmlContent = '';

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  @override
  void didUpdateWidget(HtmlScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _loadHtml();
    }
  }

  Future<void> _loadHtml() async {
    setState(() => _loading = true);
    final html = await rootBundle.loadString(widget.assetPath);
    setState(() => _htmlContent = html);
    if (_controller != null) {
      await _controller!.loadData(
        data: html,
        mimeType: 'text/html',
        encoding: 'utf-8',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialData: _htmlContent.isNotEmpty
              ? InAppWebViewInitialData(data: _htmlContent, mimeType: 'text/html', encoding: 'utf-8')
              : null,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useWideViewPort: true,
            loadWithOverviewMode: true,
            supportZoom: false,
            verticalScrollBarEnabled: false,
            transparentBackground: true,
          ),
          onWebViewCreated: (c) {
            _controller = c;
            if (_htmlContent.isNotEmpty) {
              c.loadData(data: _htmlContent, mimeType: 'text/html', encoding: 'utf-8');
            }
          },
          onLoadStop: (c, url) => setState(() => _loading = false),
          onLoadError: (c, url, code, msg) => setState(() => _loading = false),
        ),
        if (_loading)
          Container(
            color: const Color(0xFF0F0F0F),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AL-HIRFA',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('الحرفة', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
                  SizedBox(height: 32),
                  CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
