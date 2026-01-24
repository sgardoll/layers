# 05-02 Summary: App Store Prep

## Completed

### App Store Connect Entry
- **App Name:** Layers
- **Bundle ID:** com.connectio.layers
- **SKU:** com.connectio.layers
- **Apple ID:** 6758235126

### App Store Metadata
Created `APP_STORE_METADATA.md` with:
- App description (short & full)
- Keywords for ASO
- Category recommendations
- Privacy policy requirements
- In-app purchase product IDs

### In-App Purchase Products
Configured in App Store Connect:
| Product ID | Type | Price |
|------------|------|-------|
| `layers_pro_monthly` | Auto-Renewable Subscription | $4.99/month |
| `layers_pro_yearly` | Auto-Renewable Subscription | $49.99/year |

### RevenueCat Integration
- Entitlement ID: `Layers Pro`
- Products linked to RevenueCat packages

## Pending (Manual)

### Screenshots
- **iOS:** Capture from Simulator (1290x2796 for 6.7", 1242x2688 for 6.5")
- **Android:** Capture from Emulator (1080x1920 or 1920x1080)

Recommended screens:
1. Project Gallery with projects
2. 3D Layer Editor view
3. Paywall/Pro upgrade screen

## Files
- `.planning/phases/05-monetization-launch/APP_STORE_METADATA.md`

## Next
- 05-03: TestFlight build and deployment
