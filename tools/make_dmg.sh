#!/bin/bash
# Builds a Release copy of Olive Unlock and packages it as build/OliveUnlock.dmg,
# with an Applications shortcut to drag the app onto.
#
# Usage: TEAM_ID=<your Apple team ID> tools/make_dmg.sh
#
# Needs an Apple ID signed in under Xcode > Settings > Accounts: the Touch ID keychain items require a
# provisioning profile, so an ad-hoc signed build can't store the session key. A free Personal Team build
# runs only on this Mac; a Developer ID (paid) build runs on any Mac.
# Upload the resulting DMG to a GitHub Release, named exactly OliveUnlock.dmg,
# so the README's download button (releases/latest/download/OliveUnlock.dmg) finds it.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
# Built outside the repo: iCloud-synced folders like the Desktop attach extended attributes that codesign
# rejects ("resource fork, Finder information, or similar detritus not allowed").
WORK="${TMPDIR:-/tmp}/OliveUnlock-build"
DERIVED="$WORK/DerivedData"
STAGING="$WORK/dmg"
DMG="$BUILD/OliveUnlock.dmg"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING" "$BUILD"

: "${TEAM_ID:?Set TEAM_ID to your Apple team ID (Xcode > Settings > Accounts)}"

xcodebuild \
    -project "$ROOT/OliveUnlock.xcodeproj" \
    -scheme OliveUnlock \
    -configuration Release \
    -derivedDataPath "$DERIVED" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    build

APP="$DERIVED/Build/Products/Release/OliveUnlock.app"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
    -volname "Olive Unlock" \
    -srcfolder "$STAGING" \
    -fs HFS+ \
    -format UDZO \
    -ov "$WORK/OliveUnlock.dmg"
mv "$WORK/OliveUnlock.dmg" "$DMG"

rm -rf "$STAGING"
echo "Created $DMG"
