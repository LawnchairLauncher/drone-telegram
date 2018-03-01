#!/bin/bash

if [ -z "$MAJOR_MINOR" ]; then
    MAJOR_MINOR="alpha"
fi

# Adding body to changelog (intentional whitespace!!)
CHANGELOG=" <b>Changelog for build ${MAJOR_MINOR}-${DRONE_BUILD_NUMBER}</b>
$(cat changelog.txt)

<a href=\"${DRONE_REPO_LINK}/compare/${DRONE_PREV_COMMIT_SHA}..${DRONE_COMMIT_SHA}\">View on GitHub</a>"

# Preparing files to upload
cp app/build/outputs/apk/debug/app-debug.apk Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk
cp app/build/outputs/mapping/debug/mapping.txt proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt

# Post build on Telegram
curl -F chat_id="$CHANNEL_ID" -F sticker="CAADBQADKAADTBCSGmapM3AUlzaHAg" https://api.telegram.org/bot$BOT_TOKEN/sendSticker
curl -F chat_id="$CHANNEL_ID" -F document=@"Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
curl -F chat_id="$CHANNEL_ID" -F text="$CHANGELOG" -F parse_mode="HTML" https://api.telegram.org/bot$BOT_TOKEN/sendMessage
curl -F chat_id="442800997" -F document=@"proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
