package com.plantidentifier.nature.rose.identifier.plant

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    private val nativeAdFactoryIds = listOf(
        "native_1a_no_media",
        "native_1a_ad_placement",
        "native_1a",
        "native_2a",
        "native_3a",
        "native_3b",
        "native_5a",
        "native_6b",
        "native_6c",
        "native_7b",
        "native_8f",
        "native_9",
        "native_full_screen",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        nativeAdFactoryIds.forEach { factoryId ->
            GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine,
                factoryId,
                PlantNativeAdFactory(this, factoryId),
            )
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        nativeAdFactoryIds.forEach { factoryId ->
            GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, factoryId)
        }
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
