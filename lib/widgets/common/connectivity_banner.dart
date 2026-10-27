import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// يلفّ التطبيق بالكامل (عبر MaterialApp.builder) ويعرض شريطاً علوياً عند
/// انقطاع الاتصال بالإنترنت — كل الشاشات تعتمد على Firestore/Firebase Auth
/// مباشرة ولا تعمل بلا اتصال، لذا تنبيه المستخدم أفضل من فشل صامت.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_update);
    _subscription = Connectivity().onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline && mounted) setState(() => _isOffline = offline);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: _isOffline ? 28 : 0,
              width: double.infinity,
              color: Colors.red.shade800,
              alignment: Alignment.center,
              child: _isOffline
                  ? const Text('لا يوجد اتصال بالإنترنت', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                  : null,
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
