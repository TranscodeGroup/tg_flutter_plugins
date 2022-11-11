package com.transcodegroup.huawei_share

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** HuaweiSharePlugin */
class HuaweiSharePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var share: Share

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        share = Share(flutterPluginBinding.applicationContext)
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.transcodegroup/huawei_share")
        channel.setMethodCallHandler(this)

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            "isAvailable" -> result.success(share.isAvailable())
            "share"->{
                share.share(
                        text =  call.argument("text"),
                        title =  call.argument("title"),
                        subject =  call.argument("subject"),
                        paths =  call.argument("paths"),
                        mimeType =  call.argument("mimeType"),
                        fileProviderAuthority =  call.argument("fileProviderAuthority"),
                )
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        share.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        share.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()
}
