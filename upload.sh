#!/bin/bash

cp app/build/outputs/apk/debug/app-debug.apk Lawnchair-alpha_$DRONE_BUILD_NUMBER.apk
cp app/build/outputs/mapping/debug/mapping.txt proguard-alpha_$DRONE_BUILD_NUMBER.txt

curl -F chat_id="$CHANNEL_ID" -F document=@"Lawnchair-alpha_$DRONE_BUILD_NUMBER.apk" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
curl -F chat_id="$CHANNEL_ID" -F text="changelog.txt" -F parse_mode="HTML" https://api.telegram.org/bot$BOT_TOKEN/sendMessage
curl -F chat_id="442800997" -F document=@"proguard-alpha_$DRONE_BUILD_NUMBER.txt" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
