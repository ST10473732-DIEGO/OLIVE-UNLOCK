#!/bin/bash
# Builds a Release copy of Olive Unlock and packages it as build/OliveUnlock.dmg,
# with an Applications shortcut to drag the app onto.
#
# Usage: tools/make_dmg.sh
# Upload the resulting DMG to a GitHub Release, named exactly OliveUnlock.dmg,
# so the README's download button (releases/latest/download/OliveUnlock.dmg) finds it.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
DERIVED="$BUILD/DerivedData"
STAGING="$BUILD/dmg"
DMG="$BUILD/OliveUnlock.dmg"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"

# Ad-hoc signed ("-"), since no Apple Developer ID is required to build it.
xcodebuild \
    -project "$ROOT/OliveUnlock.xcodeproj" \
    -scheme OliveUnlock \
    -configuration Release \
    -derivedDataPath "$DERIVED" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="" \
    build

APP="$DERIVED/Build/Products/Release/OliveUnlock.app"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
    -volname "Olive Unlock" \
    -srcfolder "$STAGING" \
    -fs HFS+ \
    -format UDZO \
    -ov "$DMG"

rm -rf "$STAGING"
echo "Created $DMG"
