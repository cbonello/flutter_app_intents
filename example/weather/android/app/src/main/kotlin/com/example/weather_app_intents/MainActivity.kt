package com.example.weather_app_intents

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.flutter_app_intents.FlutterAppIntentsPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleAppIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAppIntent(intent)
    }

    private fun handleAppIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW) {
            val data: Uri? = intent.data
            if (data?.scheme == "app" && data.host == "intent") {
                // Extract intent identifier from URI path
                // URI format: app://intent/<identifier>
                val identifier = data.pathSegments?.firstOrNull()
                if (identifier != null) {
                    // Forward to the Flutter plugin
                    // Note: Plugin will queue this if Flutter isn't ready yet
                    FlutterAppIntentsPlugin.instance.handleIntentInvocation(
                        identifier = identifier,
                        parameters = emptyMap()
                    )
                }
            }
        }
    }
}
