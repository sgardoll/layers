# Quick Task Plan: Fix Deploy for Mac OS

## Task Summary
Fix the macOS deployment workflow that consistently fails with "No signing certificate 'Mac Development' found" error.

## Problem Analysis
- GitHub Actions workflow `build-macos.yml` fails on every run
- Error: `No signing certificate "Mac Development" found: No "Mac Development" signing certificate matching team ID "UGM4QHBM9W" with a private key was found`
- Root causes:
  1. Xcode project has conflicting signing settings (CODE_SIGN_STYLE = Automatic with hardcoded identity)
  2. Workflow may not properly configure the keychain for Flutter build
  3. Certificate type mismatch: Workflow signs with "Developer ID Application" but Xcode expects "Mac Development"

## Solution Approach
1. Update Xcode project signing configuration to use consistent settings:
   - Set CODE_SIGN_STYLE = Manual for Release builds
   - Use CODE_SIGN_IDENTITY = "Mac Developer" for CI compatibility
   - Keep DEVELOPMENT_TEAM = UGM4QHBM9W

2. Update GitHub Actions workflow:
   - Add explicit CODE_SIGN_IDENTITY override in flutter build command
   - Ensure keychain is properly set up before build
   - Add keychain search list configuration

## Files to Modify
1. `.github/workflows/build-macos.yml` - Update build step to use manual signing
2. `macos/Runner.xcodeproj/project.pbxproj` - Fix Release configuration signing settings

## Verification
- Workflow should complete without "No signing certificate" error
- PKG installer should be created successfully
- Build artifacts should be uploaded
