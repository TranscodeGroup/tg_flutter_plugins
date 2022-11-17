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
    enum class OemChooser(
            val action: String,
            val packageName: String,
    ) {
        HUAWEI("com.huawei.intent.action.hwCHOOSER", "com.huawei.android.internal.app"),
        HIHONOR("com.hihonor.intent.action.hwCHOOSER", "com.hihonor.android.internal.app")
    }

    private val context get() = activity ?: applicationContext

    fun getAvailableOemChooser(): OemChooser? =
            OemChooser.values().firstOrNull {
                val resolveInfo = context.packageManager.resolveActivity(Intent(it.action), PackageManager.MATCH_DEFAULT_ONLY)

                return@firstOrNull resolveInfo?.activityInfo?.packageName == it.packageName
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
            getAvailableOemChooser()?.let {
                action = it.action;
            }

            if (activity == null) addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        if (fileUris.isNotEmpty()) {
            // Make chooser can read fileUris
            context.packageManager.queryIntentActivities(chooserIntent, PackageManager.MATCH_DEFAULT_ONLY).forEach { info ->
                fileUris.forEach { uri ->
                    context.grantUriPermission(info.activityInfo.packageName, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
            }
        }

        context.startActivity(chooserIntent)
    }
}
