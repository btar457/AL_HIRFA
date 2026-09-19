package com.alhirfa.app

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // تشخيص مؤقّت: يعيد بصمات SHA-1 لشهادة التوقيع الفعلية للتطبيق كما يراها
        // نظام أندرويد على الجهاز نفسه — لمطابقتها مع قيود مفتاح Google API
        // (Android restrictions) دون تخمين. يُحذف بعد انتهاء التشخيص.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "al_hirfa/diagnostics")
            .setMethodCallHandler { call, result ->
                if (call.method == "signingCertificates") result.success(signingCertificates())
                else result.notImplemented()
            }
    }

    private fun signingCertificates(): Map<String, List<String>> {
        val out = mutableMapOf<String, List<String>>()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo
                if (info != null) {
                    out["current"] = info.apkContentsSigners.map { sha1(it.toByteArray()) }
                    out["history"] = (info.signingCertificateHistory ?: emptyArray()).map { sha1(it.toByteArray()) }
                }
            }
            @Suppress("DEPRECATION")
            val legacy = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES).signatures
            out["legacy"] = (legacy ?: emptyArray()).map { sha1(it.toByteArray()) }
        } catch (e: Exception) {
            out["error"] = listOf(e.toString())
        }
        return out
    }

    private fun sha1(bytes: ByteArray): String =
        MessageDigest.getInstance("SHA-1").digest(bytes).joinToString(":") { "%02X".format(it) }
}
