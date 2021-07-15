#/bin/bash

WORKING_DIR=$(pwd)

xcodebuild archive -workspace 'ShopLiveSDK.xcworkspace' -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -workspace 'ShopLiveSDK.xcworkspace' -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# XCFramework 생성
xcodebuild -create-xcframework \
-framework "${WORKING_DIR}/build/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-output "${WORKING_DIR}/build/ShopLiveSDK.xcframework"

open "${WORKING_DIR}"