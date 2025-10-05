package com.example.navigation_example

import android.content.Intent
import android.os.Bundle
import com.flutter_app_intents.FlutterAppIntentsPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW) {
            val data = intent.data
            if (data?.scheme == "app" && data.host == "intent") {
                // Extract intent ID from deep link: app://intent/{intent_id}
                val intentId = data.pathSegments.firstOrNull()
                if (intentId != null) {
                    // Pass to plugin for handling
                    FlutterAppIntentsPlugin.instance.handleIntentInvocation(
                        intentId,
                        emptyMap()
                    )
                }
            }
        }
    }
}
