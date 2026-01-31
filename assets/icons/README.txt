Icon Pack Output

iOS:
- ios/Runner/Assets.xcassets/AppIcon.appiconset/
  Contains all required PNGs + Contents.json.

Android:
- android/app/src/main/res/
  Legacy launcher icons: mipmap-*/ic_launcher.png and ic_launcher_round.png
  Adaptive icons: mipmap-*/ic_launcher_foreground.png, ic_launcher_background.png
  XML: mipmap-anydpi-v26/ic_launcher.xml and ic_launcher_round.xml

Notes:
- Source image was a single flattened icon, so adaptive foreground/background were inferred:
  background = average of corner pixels (1, 17, 68)
  foreground = scaled into the safe zone (≈66.7% of canvas)
