#!/bin/bash

# === CONFIGURATION ===
APP_NAME="ai_voice_note"  # Your Flutter macOS app name
HELPER_NAME="AudioRecorderHelper"  # Your Swift binary
SOURCE_BINARY_PATH="./macos/audioRecorderHelper/AudioRecorderHelper/$HELPER_NAME"
APP_BUNDLE_PATH="./build/macos/Build/Products/Release/${APP_NAME}.app"
DEST_PATH="${APP_BUNDLE_PATH}/Contents/Resources/$HELPER_NAME"
CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"  # Optional: replace with your identity

# === CHECKS ===
if [ ! -f "$SOURCE_BINARY_PATH" ]; then
  echo "❌ Swift helper binary not found at $SOURCE_BINARY_PATH"
  exit 1
fi

if [ ! -d "$APP_BUNDLE_PATH" ]; then
  echo "❌ App bundle not found at $APP_BUNDLE_PATH"
  exit 1
fi

# === COPY ===
mkdir -p "${APP_BUNDLE_PATH}/Contents/Resources"
cp -v "$SOURCE_BINARY_PATH" "$DEST_PATH"

# === MAKE EXECUTABLE ===
chmod +x "$DEST_PATH"
echo "✅ Helper binary copied and marked as executable."

# === (Optional) CODE SIGN ===
if [[ "$CODE_SIGN_IDENTITY" != "Developer ID Application: Your Name (TEAMID)" ]]; then
  codesign --timestamp --sign "$CODE_SIGN_IDENTITY" "$DEST_PATH"
  echo "🔏 Code signed with identity: $CODE_SIGN_IDENTITY"
else
  echo "⚠️ Skipped code signing. Set CODE_SIGN_IDENTITY in script if needed."
fi
