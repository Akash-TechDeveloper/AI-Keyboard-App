package com.example.aikeyboardapp

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.EditorInfo
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.android.FlutterView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AiKeyboardService : InputMethodService(), MethodChannel.MethodCallHandler {

    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var channel: MethodChannel? = null
    private var contextChannel: MethodChannel? = null

    companion object {
        const val ENGINE_ID = "ai_keyboard_engine"
        const val CHANNEL_NAME = "ai_keyboard/commit"
        const val CONTEXT_CHANNEL_NAME = "ai_keyboard/context"
    }

    override fun onCreate() {
        super.onCreate()
        initFlutterEngine()
    }

    private fun initFlutterEngine() {
        // Reuse cached engine or create new one
        flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (flutterEngine == null) {
            flutterEngine = FlutterEngine(this).apply {
                // Navigate to the keyboard entry point
                dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(
                        FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                        "main"
                    )
                )
                FlutterEngineCache.getInstance().put(ENGINE_ID, this)
            }
        }

        // Set up the commit MethodChannel
        channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)

        // Set up the context MethodChannel
        contextChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CONTEXT_CHANNEL_NAME)
        contextChannel?.setMethodCallHandler(AppContextHandler(this))
    }

    override fun onCreateInputView(): View {
        flutterView = FlutterView(this).apply {
            attachToFlutterEngine(flutterEngine!!)
        }
        return flutterView!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        // Notify Flutter about the active editor
        val editorData = mapOf(
            "inputType" to (info?.inputType ?: 0),
            "imeOptions" to (info?.imeOptions ?: 0),
            "packageName" to (info?.packageName ?: ""),
            "fieldId" to (info?.fieldId ?: 0),
            "actionLabel" to (info?.actionLabel?.toString() ?: "")
        )
        channel?.invokeMethod("onStartInput", editorData)
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        channel?.invokeMethod("onFinishInput", null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "commitText" -> {
                val text = call.argument<String>("text") ?: ""
                val newCursorPosition = call.argument<Int>("newCursorPosition") ?: 1
                val ic = currentInputConnection
                if (ic != null) {
                    ic.commitText(text, newCursorPosition)
                    result.success(true)
                } else {
                    result.error("NO_INPUT_CONNECTION", "No active input connection", null)
                }
            }
            "deleteSurroundingText" -> {
                val before = call.argument<Int>("before") ?: 0
                val after = call.argument<Int>("after") ?: 0
                val ic = currentInputConnection
                if (ic != null) {
                    ic.deleteSurroundingText(before, after)
                    result.success(true)
                } else {
                    result.error("NO_INPUT_CONNECTION", "No active input connection", null)
                }
            }
            "sendKeyEvent" -> {
                val keyCode = call.argument<Int>("keyCode") ?: 0
                val ic = currentInputConnection
                if (ic != null) {
                    ic.sendKeyEvent(android.view.KeyEvent(android.view.KeyEvent.ACTION_DOWN, keyCode))
                    ic.sendKeyEvent(android.view.KeyEvent(android.view.KeyEvent.ACTION_UP, keyCode))
                    result.success(true)
                } else {
                    result.error("NO_INPUT_CONNECTION", "No active input connection", null)
                }
            }
            "getEditorInfo" -> {
                val info = currentInputEditorInfo
                if (info != null) {
                    result.success(mapOf(
                        "inputType" to info.inputType,
                        "imeOptions" to info.imeOptions,
                        "packageName" to (info.packageName ?: ""),
                        "fieldId" to info.fieldId
                    ))
                } else {
                    result.success(null)
                }
            }
            "performEditorAction" -> {
                val action = call.argument<Int>("action") ?: EditorInfo.IME_ACTION_DONE
                val ic = currentInputConnection
                if (ic != null) {
                    ic.performEditorAction(action)
                    result.success(true)
                } else {
                    result.error("NO_INPUT_CONNECTION", "No active input connection", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        flutterView = null
        super.onDestroy()
    }
}
