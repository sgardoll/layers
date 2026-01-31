# Deployment Secrets Setup

This document describes the GitHub Secrets required for automated builds and deployments.

## iOS (TestFlight) Secrets

Uses **Transporter** (`xcrun iTMSTransporter`) for reliable uploads to App Store Connect.

### Required Secrets

| Secret | Description | How to Obtain |
|--------|-------------|---------------|
| `IOS_CERTIFICATE_BASE64` | Base64-encoded distribution certificate (.p12) | Export from Keychain or Apple Developer Portal |
| `IOS_CERTIFICATE_PASSWORD` | Password for the certificate | Set when exporting certificate |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded App Store provisioning profile | Download from Apple Developer Portal |
| `IOS_KEYCHAIN_PASSWORD` | Temporary keychain password (any secure value) | Generate a random password |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | App Store Connect > Users and Access > Keys |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect API Issuer ID | App Store Connect > Users and Access > Keys |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64-encoded API key (.p8 file) | Download when creating API key |

### Setup Instructions

1. **Distribution Certificate**:
   ```bash
   # Export certificate from Keychain Access
   # Right-click certificate > Export > .p12 format
   # Then encode:
   base64 -i certificate.p12 | pbcopy
   ```

2. **Provisioning Profile**:
   ```bash
   # Download from Apple Developer Portal
   # Then encode:
   base64 -i Layers_App_Store.mobileprovision | pbcopy
   ```

3. **App Store Connect API Key**:
   - Go to App Store Connect > Users and Access > Keys
   - Create new key with **App Manager** role
   - Download the .p8 file (can only be downloaded once!)
   - Encode: `base64 -i AuthKey_XXXXXX.p8 | pbcopy`

## Android (Play Console + APK) Secrets

Builds both **AAB** (for Play Store) and **APK** (for sideloading/testing).

### Required Secrets

| Secret | Description | How to Obtain |
|--------|-------------|---------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore (.jks) | `base64 -i keystore.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | From keystore creation |
| `ANDROID_KEY_ALIAS` | Key alias in keystore | From keystore creation |
| `ANDROID_KEY_PASSWORD` | Key password | From keystore creation |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Service account JSON for Play Console API | Google Cloud Console + Play Console |

### Setup Instructions

1. **Keystore** (if not existing):
   ```bash
   keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   # Then encode:
   base64 -i keystore.jks | pbcopy
   ```

2. **Service Account**:
   - Go to Google Cloud Console > IAM & Admin > Service Accounts
   - Create new service account
   - Grant **Firebase App Distribution Admin** and **Service Account User** roles
   - Create key (JSON) and download
   - Go to Play Console > Setup > API Access
   - Link the service account
   - Grant **Release Manager** permission
   - Copy the entire JSON content as the secret value

## macOS (PKG) Secrets

Builds **PKG installer** for distribution outside Mac App Store.

### Required Secrets

| Secret | Description | How to Obtain |
|--------|-------------|---------------|
| `MAC_CERTIFICATE_BASE64` | Base64-encoded Developer ID certificate (.p12) | Export from Keychain |
| `MAC_CERTIFICATE_PASSWORD` | Password for the certificate | Set when exporting certificate |
| `MAC_PROVISIONING_PROFILE_BASE64` | Base64-encoded Developer ID provisioning profile | Download from Apple Developer Portal |
| `MAC_KEYCHAIN_PASSWORD` | Temporary keychain password | Generate a random password |

## Usage

### Deploy to TestFlight

1. Go to GitHub Actions > "Deploy to TestFlight"
2. Click "Run workflow"
3. Enter version (e.g., `1.1.3`) and build number (e.g., `16`)

### Deploy to Play Console + Download APK

1. Go to GitHub Actions > "Deploy to Play Console"
2. Click "Run workflow"
3. Enter version, build number, and select track (internal/alpha/beta/production)
4. After run completes, download the APK artifact from the workflow summary

### Build macOS PKG

1. Go to GitHub Actions > "Build macOS PKG"
2. Click "Run workflow"
3. Enter version and build number
4. After run completes, download the PKG artifact from the workflow summary

## Troubleshooting

### iOS

- **Certificate errors**: Ensure certificate is for Distribution (not Development)
- **Provisioning profile**: Must match the bundle ID `com.connectio.layers`
- **2FA issues**: Use App Store Connect API key (not Apple ID password)

### Android

- **Keystore errors**: Verify all passwords and alias match exactly
- **Play Console API**: Ensure service account has Release Manager permission
- **AAB build**: Make sure `flutter build appbundle` works locally first

## Local Testing

Test builds locally before deploying:

```bash
# iOS
flutter build ipa --release

# Android
flutter build appbundle --release
```
