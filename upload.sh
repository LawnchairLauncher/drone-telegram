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

if [ -z "$PLUGIN_PUBLIC_BRANCH" ]; then
    PLUGIN_PUBLIC_BRANCH="master"
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

# Fix dashes in MAJOR_MINOR to not break tags
MAJOR_MINOR=$(echo "${MAJOR_MINOR}" | sed -r 's/-/_/g')

# Adding body to changelog (intentional whitespace!!)
CHANGELOG=" <b>Changelog for build ${MAJOR_MINOR}-${DRONE_BUILD_NUMBER}:</b>
$(cat changelog.txt)"

# Preparing files to upload
cp $PLUGIN_APK_PATH Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk
cp $PLUGIN_MAPPING_PATH proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt

# Check if build should be uploaded to public, else add link to changelog
if [ $DRONE_BRANCH = $PLUGIN_PUBLIC_BRANCH ]; then
    CHANNEL_ID=${PLUGIN_CHANNEL_ID}
else
    CHANGELOG=${CHANGELOG}$'\n\n'"<a href=\"${GITHUB_LINK}\">View on GitHub</a>"
fi

# Post build on Telegram
curl -F chat_id="$CHANNEL_ID" -F disable_notification="true" -F sticker="CAADBAADcQAE8E4VflNGPzVDjI0C" https://api.telegram.org/bot$BOT_TOKEN/sendSticker
curl -F chat_id="$CHANNEL_ID" -F disable_notification="true" -F document=@"Lawnchair-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.apk" -F caption="#${MAJOR_MINOR}" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
curl -F chat_id="$CHANNEL_ID" -F text="$CHANGELOG" -F parse_mode="HTML" -F disable_web_page_preview="true" https://api.telegram.org/bot$BOT_TOKEN/sendMessage

# Send proguard file to developer
if [ $DRONE_BUILD_EVENT = "tag" ]; then
    curl -F chat_id="$DEV_CHANNEL_ID" -F document=@"proguard-${MAJOR_MINOR}_$DRONE_BUILD_NUMBER.txt" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
fi
