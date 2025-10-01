package com.example.talent_flow

import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printKeyHash()
    }

    private fun printKeyHash() {
        try {
            @Suppress("DEPRECATION")
            val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
            )

            @Suppress("DEPRECATION")
            val signatures = info.signatures

            // ✅ نتحقق إن مش null
            if (signatures != null) {
                for (signature in signatures) {
                    val md = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val keyHash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                    Log.d("KeyHash", "Facebook KeyHash: $keyHash")
                }
            } else {
                Log.e("KeyHash", "No signatures found")
            }

        } catch (e: Exception) {
            Log.e("KeyHash", "Error getting key hash", e)
        }
    }
}
