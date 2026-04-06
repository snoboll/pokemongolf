#!/bin/bash
# Pokemon Golf - Ad-hoc release script
# Usage: ./distribution/release.sh <version>
# Example: ./distribution/release.sh 1.0.1
#
# Prerequisites:
#   - Ad-hoc provisioning profile installed in Xcode
#   - SUPABASE_SERVICE_KEY set in environment (or hardcode below)

set -e

VERSION=${1:-"1.0.0"}
SUPABASE_URL="https://cuwcunjtervjelgomeil.supabase.co"
SUPABASE_KEY="${SUPABASE_SERVICE_KEY}"
BUCKET="app-distribution"
BUILD_DIR="build/ios/ipa"

echo "🏌️  Pokemon Golf release v$VERSION"

# 1. Build IPA
echo "📦 Building IPA..."
flutter build ipa \
  --export-options-plist distribution/ExportOptions.plist

IPA_PATH=$(find "$BUILD_DIR" -name "*.ipa" | head -1)
if [ -z "$IPA_PATH" ]; then
  echo "❌ IPA not found in $BUILD_DIR"
  exit 1
fi
echo "✅ IPA built: $IPA_PATH"

# 2. Update version in manifest and install page
sed -i '' "s/<string>[0-9.]*<\/string>\(<\/dict>\)/<string>$VERSION<\/string>\1/" distribution/manifest.plist
sed -i '' "s/v[0-9.]*/v$VERSION/" distribution/index.html

# 3. Upload IPA
echo "⬆️  Uploading IPA..."
curl -s -X POST "$SUPABASE_URL/storage/v1/object/$BUCKET/pokemon_golf.ipa" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/octet-stream" \
  -H "x-upsert: true" \
  --data-binary @"$IPA_PATH"
echo ""

# 4. Upload manifest
echo "⬆️  Uploading manifest..."
curl -s -X POST "$SUPABASE_URL/storage/v1/object/$BUCKET/manifest.plist" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: text/xml" \
  -H "x-upsert: true" \
  --data-binary @distribution/manifest.plist
echo ""

# 5. Upload install page
echo "⬆️  Uploading install page..."
curl -s -X POST "$SUPABASE_URL/storage/v1/object/$BUCKET/index.html" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: text/html" \
  -H "x-upsert: true" \
  --data-binary @distribution/index.html
echo ""

echo ""
echo "✅ Done! Share this link with friends (open in Safari on iPhone):"
echo "   $SUPABASE_URL/storage/v1/object/public/$BUCKET/index.html"
