package com.transcodegroup.huawei_share

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import java.io.File

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

    fun share(
            text: String?,
            title: String?,
            subject: String?,
            paths: List<String>?,
            mimeType: String?,
            fileProviderAuthority: String?,
    ) {
        require(!(paths != null && fileProviderAuthority == null)) {
            "When sharing files, be sure to specify `fileProviderAuthority`\n" +
                    "see: https://developer.android.com/training/secure-file-sharing"
        }

        val fileUris = (paths
                ?: emptyList()).mapTo(ArrayList()) { FileProvider.getUriForFile(context, fileProviderAuthority!!, File(it)) }

        val intent = Intent(Intent.ACTION_SEND).apply {
            if (text != null) putExtra(Intent.EXTRA_TEXT, text)
            if (subject != null) putExtra(Intent.EXTRA_SUBJECT, subject)
            if (title != null) putExtra(Intent.EXTRA_TITLE, title)

            if (fileUris.isEmpty()) {
                type = mimeType ?: "text/plain"
            } else {
                type = mimeType ?: "*/*"
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                if (fileUris.size == 1) {
                    putExtra(Intent.EXTRA_STREAM, fileUris.first())
                } else {
                    action = Intent.ACTION_SEND_MULTIPLE
                    putParcelableArrayListExtra(Intent.EXTRA_STREAM, fileUris)
                }

            }
        }

        val chooserIntent = Intent.createChooser(intent, null).apply {
            if (isAvailable()) {
                action = ACTION_HW_CHOOSER
            }

            if (activity == null) addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        context.startActivity(chooserIntent)
    }
}
