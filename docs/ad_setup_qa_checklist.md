# Ad Setup QA Checklist

## Implemented Placements

- Splash interstitial: code-only, shown after splash work and before launch navigation.
- App open ad: Remote Config controlled, foreground resume only, skipped on cold launch.
- Main banner: Remote Config controlled adaptive/collapsible banner near the bottom navigation.
- Onboarding native: Remote Config controlled full-screen native between onboarding page 2 and page 3.
- Home native ads: Remote Config controlled placements under Identify and Diagnose.
- Route/fragment shift interstitial: Remote Config controlled, click capped, timer gated, excludes Pro and Settings actions.
- Processing-result rewarded interstitial: code-only, triggered only when closing Premium after processing.

## Code-Only Placements

- Splash interstitial uses `splashInterstitialAdId`.
- Processing-result rewarded interstitial uses `rewardedInterstitialAfterPremiumAdId`.
- These placements intentionally have no Remote Config on/off keys.

## Remote Config Placements

- App open: `isAdsMasterEnabled`, `appOpenEnabled`, `appOpenAdId`.
- Banner: `isAdsMasterEnabled`, `bannerEnabled`, `bannerAdId`, `bannerType`.
- Onboarding native: `isAdsMasterEnabled`, `onboardingNativeEnabled`, `onboardingNativeAdId`, `onboardingNativeVariant`, native colors.
- Home native 1/2: `isAdsMasterEnabled`, per-placement enabled/ad ID/variant, native colors.
- Route shift interstitial: `isAdsMasterEnabled`, `shiftInterstitialEnabled`, ad ID, click cap, timer, loader timer.

## Manual Test Checklist

- Fresh launch: Splash > interstitial attempt > Premium > Language > Onboarding > Main.
- Returning launch: Splash > interstitial attempt > Premium > Main.
- Close launch Premium and confirm no rewarded interstitial appears.
- Background and resume after launch; app open should show only if enabled and loaded.
- Disable each Remote Config placement and confirm that placement disappears or does not show.
- Tap eligible Home navigation/actions repeatedly and confirm route-shift cap, timer, loader, and fail-safe navigation.
- Tap Pro and Settings actions and confirm they do not show or increment route-shift interstitials.
- Move from onboarding page 2 to page 3 and confirm native ad appears once when enabled, then continues safely.
- Run identify, diagnose, and water flows; after processing, Premium appears, close attempts rewarded interstitial, then correct result opens.
- Turn off internet and confirm no stuck loader, no blocked navigation, and no crashes.

## Known Limitations

- Android native ad factories currently map all factory IDs to one shared base renderer. Per-variant pixel-perfect native Android layouts can be refined later if PM requires exact live native rendering.

## Production Checklist

- Replace Google test App ID and test ad unit IDs only when ready for production release.
- Verify AdMob account policy requirements for each native layout before production IDs are used.
- Re-run `flutter analyze` and a debug/release Android build after replacing IDs.
