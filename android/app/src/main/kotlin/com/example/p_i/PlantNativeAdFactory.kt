package com.plantidentifier.nature.rose.identifier.plant

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.AdChoicesView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class PlantNativeAdFactory(
    private val context: Context,
    private val registeredFactoryId: String,
) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val variantId = customOptions?.get("variant")?.toString() ?: registeredFactoryId
        val textColor = readColor(customOptions, "textColor", Color.parseColor("#333333"))
        val ctaStartColor = readColor(customOptions, "ctaColor", Color.parseColor("#00ACC4"))
        val ctaEndColor = readColor(customOptions, "ctaEndColor", Color.parseColor("#0BAC8B"))

        val nativeAdView = NativeAdView(context).apply {
            tag = variantId
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            )
        }

        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(10), dp(10), dp(10), dp(10))
            background = roundedDrawable(Color.WHITE, dpFloat(8))
        }
        nativeAdView.addView(
            root,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        val mediaFrame = FrameLayout(context)
        val mediaView = MediaView(context).apply {
            nativeAd.mediaContent?.let { mediaContent = it }
            background = roundedDrawable(Color.parseColor("#EEF3FB"), 0f)
        }
        mediaFrame.addView(
            mediaView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(132),
            ),
        )

        val adChoicesView = AdChoicesView(context)
        mediaFrame.addView(
            adChoicesView,
            FrameLayout.LayoutParams(
                dp(32),
                dp(32),
                Gravity.TOP or Gravity.END,
            ),
        )
        root.addView(
            mediaFrame,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(132),
            ),
        )

        val contentRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, dp(10), 0, 0)
        }
        root.addView(
            contentRow,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        val iconView = ImageView(context).apply {
            scaleType = ImageView.ScaleType.CENTER_CROP
            background = roundedDrawable(Color.parseColor("#070712"), dpFloat(8))
        }
        contentRow.addView(
            iconView,
            LinearLayout.LayoutParams(dp(46), dp(46)).apply {
                marginEnd = dp(10)
            },
        )

        val textColumn = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
        }
        contentRow.addView(
            textColumn,
            LinearLayout.LayoutParams(
                0,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                1f,
            ).apply {
                marginEnd = dp(10)
            },
        )

        val titleRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        textColumn.addView(
            titleRow,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        val headlineView = TextView(context).apply {
            text = nativeAd.headline.orEmpty()
            setTextColor(textColor)
            setTypeface(typeface, Typeface.BOLD)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
        }
        titleRow.addView(
            headlineView,
            LinearLayout.LayoutParams(
                0,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                1f,
            ).apply {
                marginEnd = dp(6)
            },
        )

        val adBadgeView = TextView(context).apply {
            text = "Ad"
            setTextColor(Color.WHITE)
            setTypeface(typeface, Typeface.BOLD)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f)
            gravity = Gravity.CENTER
            background = roundedDrawable(Color.parseColor("#D39800"), dpFloat(3))
            setPadding(dp(5), dp(1), dp(5), dp(1))
        }
        titleRow.addView(
            adBadgeView,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        val bodyView = TextView(context).apply {
            text = nativeAd.body.orEmpty()
            setTextColor(textColor)
            alpha = 0.78f
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            maxLines = 2
            ellipsize = android.text.TextUtils.TruncateAt.END
        }
        textColumn.addView(
            bodyView,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply {
                topMargin = dp(2)
            },
        )

        val advertiserView = TextView(context).apply {
            text = nativeAd.advertiser.orEmpty()
            setTextColor(textColor)
            alpha = 0.62f
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 10f)
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
        }
        textColumn.addView(
            advertiserView,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )

        val ctaButton = Button(context).apply {
            text = nativeAd.callToAction.orEmpty()
            setTextColor(Color.WHITE)
            setTypeface(typeface, Typeface.BOLD)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            minHeight = 0
            minWidth = 0
            minimumHeight = 0
            minimumWidth = 0
            includeFontPadding = false
            stateListAnimator = null
            background = GradientDrawable(
                GradientDrawable.Orientation.LEFT_RIGHT,
                intArrayOf(ctaStartColor, ctaEndColor),
            ).apply {
                cornerRadius = dpFloat(18)
            }
        }
        contentRow.addView(
            ctaButton,
            LinearLayout.LayoutParams(dp(86), dp(38)),
        )

        nativeAdView.mediaView = mediaView
        nativeAdView.adChoicesView = adChoicesView
        nativeAdView.iconView = iconView
        nativeAdView.headlineView = headlineView
        nativeAdView.bodyView = bodyView
        nativeAdView.advertiserView = advertiserView
        nativeAdView.callToActionView = ctaButton

        val icon = nativeAd.icon
        if (icon == null) {
            iconView.visibility = View.GONE
        } else {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        }

        bodyView.visibility = if (nativeAd.body.isNullOrBlank()) View.GONE else View.VISIBLE
        advertiserView.visibility =
            if (nativeAd.advertiser.isNullOrBlank()) View.GONE else View.VISIBLE
        ctaButton.visibility =
            if (nativeAd.callToAction.isNullOrBlank()) View.GONE else View.VISIBLE

        // TODO(ads): Replace this shared renderer with per-variant Android layouts
        // matching the Phase 1 Figma designs before native ads are placed in screens.
        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }

    private fun readColor(
        customOptions: Map<String, Any>?,
        key: String,
        fallback: Int,
    ): Int {
        val value = customOptions?.get(key)?.toString() ?: return fallback
        return try {
            Color.parseColor(value)
        } catch (_: IllegalArgumentException) {
            fallback
        }
    }

    private fun roundedDrawable(color: Int, radius: Float): GradientDrawable {
        return GradientDrawable().apply {
            setColor(color)
            cornerRadius = radius
        }
    }

    private fun dp(value: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            context.resources.displayMetrics,
        ).toInt()
    }

    private fun dpFloat(value: Int): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            context.resources.displayMetrics,
        )
    }
}
