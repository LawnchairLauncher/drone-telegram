#!/bin/bash

cp app/build/outputs/apk/debug/app-debug.apk Lawnchair-$MAJOR_MINOR.$TRAVIS_BUILD_NUMBER.apk
cp app/build/outputs/mapping/debug/mapping.txt proguard-$MAJOR_MINOR.$TRAVIS_BUILD_NUMBER.txt

curl -F chat_id="-1001083653933" -F document=@"Lawnchair-$MAJOR_MINOR.$TRAVIS_BUILD_NUMBER.apk" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
curl -F chat_id="-1001083653933" -F text="changelog.txt" -F parse_mode="HTML" https://api.telegram.org/bot$BOT_TOKEN/sendMessage
curl -F chat_id="442800997" -F document=@"proguard-$MAJOR_MINOR.$TRAVIS_BUILD_NUMBER.txt" https://api.telegram.org/bot$BOT_TOKEN/sendDocument
