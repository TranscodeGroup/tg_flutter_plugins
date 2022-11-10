package com.transcodegroup.huawei_share

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager

internal class Share(
        private val applicationContext: Context,
        var activity: Activity? = null,
) {
    companion object {
        const val ACTION_HW_CHOOSER = "com.huawei.intent.action.hwCHOOSER"
        const val HW_CHOOSER_PACKAGE_NAME = "com.huawei.android.internal.app"
    }

    private val context get() = activity ?: applicationContext

    fun isAvailable(): Boolean {
        val resolveInfo = context.packageManager.resolveActivity(Intent(ACTION_HW_CHOOSER), PackageManager.MATCH_DEFAULT_ONLY)

        return resolveInfo?.activityInfo?.packageName == HW_CHOOSER_PACKAGE_NAME
    }
}