#!/bin/bash
# Spotify OAuth Token Manager for macOS Keychain
#
# One-time setup:
#   security add-generic-password -a spotify -s spotify_client_id -w "<YOUR_CLIENT_ID>"
#   security add-generic-password -a spotify -s spotify_client_secret -w "<YOUR_CLIENT_SECRET>"
#   security add-generic-password -a spotify -s spotify_refresh_token -w "<YOUR_REFRESH_TOKEN>"

set -euo pipefail

keychain_get() {
  security find-generic-password -a spotify -s "$1" -w 2>/dev/null
}

keychain_set() {
  security delete-generic-password -a spotify -s "$1" 2>/dev/null || true
  security add-generic-password -a spotify -s "$1" -w "$2"
}

# Read credentials
CLIENT_ID=$(keychain_get spotify_client_id) || { echo "ERROR:missing_client_id"; exit 1; }
CLIENT_SECRET=$(keychain_get spotify_client_secret) || { echo "ERROR:missing_client_secret"; exit 1; }
REFRESH_TOKEN=$(keychain_get spotify_refresh_token) || { echo "ERROR:missing_refresh_token"; exit 1; }

# Check cached token
CACHED_TOKEN=$(keychain_get spotify_access_token 2>/dev/null || echo "")
CACHED_EXPIRY=$(keychain_get spotify_token_expiry 2>/dev/null || echo "0")
NOW=$(date +%s)

# Use cached token if still valid (60s buffer)
if [ -n "$CACHED_TOKEN" ] && [ "$CACHED_EXPIRY" -gt "$((NOW + 60))" ] 2>/dev/null; then
  echo "$CACHED_TOKEN"
  exit 0
fi

# Refresh the token
RESPONSE=$(curl -s --max-time 10 -X POST "https://accounts.spotify.com/api/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=refresh_token" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET")

# Parse response
ACCESS_TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
EXPIRES_IN=$(echo "$RESPONSE" | grep -o '"expires_in":[0-9]*' | cut -d: -f2)

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR:token_refresh_failed"
  exit 1
fi

# Cache token and expiry
EXPIRY=$((NOW + EXPIRES_IN))
keychain_set spotify_access_token "$ACCESS_TOKEN"
keychain_set spotify_token_expiry "$EXPIRY"

echo "$ACCESS_TOKEN"
