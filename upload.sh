#!/bin/bash

if [ -z "$MAJOR_MINOR" ]; then
    MAJOR_MINOR="alpha"
fi

if [ -z "$APK_PATH" ]; then
    APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
fi

if [ -z "$MAPPING_PATH" ]; then
    MAPPING_PATH="app/build/outputs/mapping/debug/mapping.txt"
fi

if [ -z "$DEV_CHANNEL_ID" ]; then
    DEV_CHANNEL_ID="442800997"
fi

# Adding body to changelog (intentional whitespace!!)
CHANGELOG=" <b>Changelog for build ${MAJOR_MINOR}-${DRONE_BUILD_NUMBER}</b>
$(cat changelog.txt)

<a href=\"${DRONE_REPO_LINK}/compare/${DRONE_PREV_COMMIT_SHA:0:8}...${DRONE_COMMIT_SHA:0:8}\">View on GitHub</a>"

# Preparing files to upload
cp $APK_PATH Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk
cp $MAPPING_PATH proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt

# Post build on Telegram
curl -F chat_id="$CHANNEL_ID" -F sticker="CAADBQADKAADTBCSGmapM3AUlzaHAg" https://api.telegram.org/bot$BOT_TOKEN/sendSticker
curl -F chat_id="$CHANNEL_ID" -F document=@"Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
curl -F chat_id="$CHANNEL_ID" -F text="$CHANGELOG" -F parse_mode="HTML" -F disable_web_page_preview="true" https://api.telegram.org/bot$BOT_TOKEN/sendMessage
curl -F chat_id="$DEV_CHANNEL_ID" -F document=@"proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
