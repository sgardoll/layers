# Deployment Guide: v1.1.4 (Build 21)

## Build Status
✅ iOS: Built successfully (43.6MB)  
✅ Android: Built successfully (50.3MB)  
✅ All fixes committed and tested

## What's New in v1.1.4

### Features
- **Export Screen Thumbnails**: Export history now shows actual project thumbnails instead of generic blue squares
- **RevenueCat Real-time Updates**: Pro subscription status updates immediately when customer info changes

### Bug Fixes
- **Fixed**: Riverpod dependency override crash on logout/Settings navigation
- **Fixed**: Settings screen showing "Free" for Pro users
- **Fixed**: Export screen showing blue squares instead of project thumbnails

### Technical Changes
- Simplified entitlement provider architecture
- Added RevenueCat customer info update listener
- Export service now joins with projects table to fetch thumbnails

---

## iOS Deployment (TestFlight)

### Prerequisites
- Xcode 15+
- Valid Apple Developer account
- App Store Connect access
- Signing certificates and provisioning profiles

### Steps

1. **Open Xcode project**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing**:
   - Select "Runner" target
   - Go to Signing & Capabilities
   - Select your team
   - Ensure bundle ID: `com.connectio.layers`

3. **Archive the build**:
   - Product → Archive
   - Wait for build to complete
   - Distribute App → App Store Connect → Upload

4. **Upload to TestFlight**:
   - Use Xcode Organizer or Transporter app
   - Build will appear in App Store Connect within 10-30 minutes

5. **Submit for TestFlight testing**:
   - Go to App Store Connect → My Apps → Layers → TestFlight
   - Select the new build
   - Add to group for internal testing
   - (Optional) Submit for external beta review

---

## Android Deployment (Play Store)

### Prerequisites
- Android Studio or command line tools
- Google Play Console access
- Signing keystore

### Steps

1. **Build App Bundle** (already done):
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

2. **Sign the bundle** (if not already signed):
   - Ensure `android/key.properties` exists with keystore info
   - Or sign manually using jarsigner

3. **Upload to Play Console**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Select "Layers" app
   - Go to Production (or Internal Testing)
   - Click "Create new release"
   - Upload the `.aab` file
   - Add release notes

4. **Release notes template**:
   ```
   What's new in v1.1.4:
   - Export screen now displays project thumbnails
   - Fixed subscription status display in Settings
   - Improved app stability
   ```

5. **Review and rollout**:
   - Review changes
   - Save and send for review (if required)
   - Roll out to production when ready

---

## macOS Deployment (App Store)

### Steps

1. **Build for macOS**:
   ```bash
   flutter build macos --release
   ```

2. **Open in Xcode**:
   ```bash
   open macos/Runner.xcworkspace
   ```

3. **Archive and upload**:
   - Product → Archive
   - Distribute App → App Store Connect → Upload

---

## Post-Deployment Checklist

- [ ] iOS build uploaded to TestFlight
- [ ] Android build uploaded to Play Console
- [ ] macOS build uploaded to App Store Connect
- [ ] TestFlight internal testing group has access
- [ ] Android internal testing track has access
- [ ] Smoke test on physical devices
- [ ] Monitor crash reports
- [ ] Update app store screenshots if needed

---

## Build Artifacts Location

| Platform | Location |
|----------|----------|
| iOS | `build/ios/iphoneos/Runner.app` |
| Android | `build/app/outputs/bundle/release/app-release.aab` |
| macOS | `build/macos/Build/Products/Release/layers.app` |

---

## Version Info
- **Version**: 1.1.4
- **Build**: 21
- **Bundle ID**: com.connectio.layers
- **Commit**: a940533 (latest)

---

## Need Help?

If you encounter issues during deployment:

1. **iOS signing issues**: Check certificates in Apple Developer portal
2. **Android keystore issues**: Verify `android/key.properties` configuration
3. **Build failures**: Run `flutter clean` then rebuild
4. **Upload failures**: Check network and retry

---

*Generated: 2026-02-06*  
*Ready for deployment*
