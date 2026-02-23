package com.example.aikeyboardapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the app context channel so the main activity can also detect foreground apps
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ai_keyboard/context"
        ).setMethodCallHandler(AppContextHandler(this))
    }
}
