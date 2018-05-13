#!/bin/bash

if [ -z "$MAJOR_MINOR" ]; then
    MAJOR_MINOR="alpha"
fi

if [ -z "$PLUGIN_APK_PATH" ]; then
    PLUGIN_APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
fi

if [ -z "$PLUGIN_MAPPING_PATH" ]; then
    PLUGIN_MAPPING_PATH="app/build/outputs/mapping/debug/mapping.txt"
fi

if [ -z "$PLUGIN_CHANNEL_ID" ]; then
    PLUGIN_CHANNEL_ID="-1001180711841"
fi

# Check cache for previous commit hash
if [ -f ".last_commit" ]; then
    DRONE_PREV_COMMIT_SHA="$(cat .last_commit)"
fi

# Check if this is a clean build
if [ -f ".clean" ]; then
    GITHUB_LINK="${DRONE_REPO_LINK}/commit/${DRONE_COMMIT_SHA}"
else
    GITHUB_LINK="${DRONE_REPO_LINK}/compare/${DRONE_PREV_COMMIT_SHA:0:8}...${DRONE_COMMIT_SHA:0:8}"
fi

# Adding body to changelog (intentional whitespace!!)
CHANGELOG=" <b>Changelog for build ${MAJOR_MINOR}-${DRONE_BUILD_NUMBER}</b>
$(cat changelog.txt)

<a href=\"${GITHUB_LINK}\">View on GitHub</a>"

# Preparing files to upload
cp $PLUGIN_APK_PATH Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk
cp $PLUGIN_MAPPING_PATH proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt

# Post build on Telegram
curl -F chat_id="$PLUGIN_CHANNEL_ID" -F sticker="CAADBQADKAADTBCSGmapM3AUlzaHAg" https://api.telegram.org/bot$BOT_TOKEN/sendSticker
curl -F chat_id="$PLUGIN_CHANNEL_ID" -F document=@"Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
curl -F chat_id="$PLUGIN_CHANNEL_ID" -F text="$CHANGELOG" -F parse_mode="HTML" -F disable_web_page_preview="true" https://api.telegram.org/bot$BOT_TOKEN/sendMessage
curl -F chat_id="$CHANNEL_ID" -F document=@"proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
