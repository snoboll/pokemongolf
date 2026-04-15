#!/bin/bash
# Upload latest exported IPA to Supabase
# Usage: bogeybeastupdate
# Set SUPABASE_SERVICE_KEY in your shell profile

set -e

SUPABASE_URL="https://cuwcunjtervjelgomeil.supabase.co"
SUPABASE_KEY="${SUPABASE_SERVICE_KEY}"
BUCKET="app-distribution"

if [ -z "$SUPABASE_KEY" ]; then
  echo "❌ SUPABASE_SERVICE_KEY not set. Add it to your ~/.zshrc"
  exit 1
fi

# Find the most recently modified IPA in ~/Stuff (recursive)
IPA_PATH=$(find ~/Stuff -name "*.ipa" 2>/dev/null | while IFS= read -r f; do echo "$(stat -f '%m' "$f") $f"; done | sort -rn | head -1 | cut -d' ' -f2-)

if [ -z "$IPA_PATH" ]; then
  echo "❌ No .ipa found in ~/Stuff. Export from Xcode Organizer first."
  exit 1
fi

echo "📦 Found IPA: $IPA_PATH"
echo "⬆️  Uploading..."

curl -s -X PUT "$SUPABASE_URL/storage/v1/object/$BUCKET/bogeybeasts.ipa" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/octet-stream" \
  -H "x-upsert: true" \
  --data-binary "@$IPA_PATH"

echo ""
echo "✅ Done! Install link:"
echo "   https://cuwcunjtervjelgomeil.supabase.co/storage/v1/object/public/$BUCKET/index.html"
