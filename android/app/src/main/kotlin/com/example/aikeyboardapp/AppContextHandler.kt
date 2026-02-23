package com.example.aikeyboardapp

import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppContextHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getForegroundApp" -> {
                try {
                    val foregroundApp = getForegroundAppInfo()
                    result.success(foregroundApp)
                } catch (e: Exception) {
                    result.error("CONTEXT_ERROR", "Failed to get foreground app: ${e.message}", null)
                }
            }
            "hasUsageStatsPermission" -> {
                result.success(hasUsageStatsPermission())
            }
            else -> result.notImplemented()
        }
    }

    private fun getForegroundAppInfo(): Map<String, String> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
        if (usageStatsManager != null && hasUsageStatsPermission()) {
            val endTime = System.currentTimeMillis()
            val startTime = endTime - 5000 // last 5 seconds
            val usageStatsList = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY, startTime, endTime
            )
            if (usageStatsList != null && usageStatsList.isNotEmpty()) {
                val sortedStats = usageStatsList.sortedByDescending { it.lastTimeUsed }
                val topPackage = sortedStats.firstOrNull()?.packageName ?: "unknown"
                val appName = getAppName(topPackage)
                return mapOf(
                    "appName" to appName,
                    "packageName" to topPackage
                )
            }
        }

        // Fallback: return unknown
        return mapOf(
            "appName" to "Unknown",
            "packageName" to "unknown"
        )
    }

    private fun getAppName(packageName: String): String {
        return try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            packageName.substringAfterLast(".")
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return false
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 60000
        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        return stats != null && stats.isNotEmpty()
    }
}
