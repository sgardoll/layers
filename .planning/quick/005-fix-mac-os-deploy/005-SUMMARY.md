# Quick Task Summary: Fix Deploy for Mac OS

## Issue
The macOS deployment workflow was consistently failing with:
```
error: No signing certificate "Mac Development" found: 
No "Mac Development" signing certificate matching team ID "UGM4QHBM9W" 
with a private key was found.
```

## Root Causes
1. **Xcode project had conflicting signing settings**:
   - `CODE_SIGN_STYLE = Automatic` but with hardcoded `CODE_SIGN_IDENTITY`
   - Identity was set to "3rd Party Mac Developer Application" (App Store) 
   - But CI was importing "Developer ID Application" (distribution)
   - Xcode expected "Mac Development" certificate but CI had Developer ID

2. **Workflow missing keychain configuration**:
   - Keychain wasn't added to search list for Xcode
   - Keychain wasn't unlocked before Flutter build
   - No debug output to verify imported certificates

## Changes Made

### 1. `.github/workflows/build-macos.yml`
- Added keychain to search list so Xcode can find certificates
- Added keychain unlock before Flutter build
- Added certificate listing for debugging
- Updated build command with dart-define flags

### 2. `macos/Runner.xcodeproj/project.pbxproj`
- Changed Release configuration:
  - `CODE_SIGN_STYLE` from `Automatic` to `Manual`
  - `CODE_SIGN_IDENTITY` to `"Developer ID Application"`
  - Removed conflicting `"CODE_SIGN_IDENTITY[sdk=macosx*]"` entry
- Changed Profile configuration:
  - Same changes as Release
  - Added missing build settings

## Testing
Next macOS build should:
1. Complete without "No signing certificate" error
2. Successfully create PKG installer
3. Upload artifact to GitHub

## Commit
- **Hash**: `9a9544d`
- **Message**: fix(macos): resolve code signing configuration for CI deployment
