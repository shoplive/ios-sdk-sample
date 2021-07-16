#/bin/bash

WORKING_DIR=$(pwd)

xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/min13/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/min13/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# XCFramework 생성
xcodebuild -create-xcframework \
-framework "${WORKING_DIR}/build/min13/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/min13/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-output "${WORKING_DIR}/build/min13/ShopLiveSDK_MinVer13.xcframework"

xcodebuild archive -workspace 'ShopLiveSDK.xcworkspace' -scheme ShopLiveSDKRx -archivePath "${WORKING_DIR}/build/min11/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -workspace 'ShopLiveSDK.xcworkspace' -scheme ShopLiveSDKRx -archivePath "${WORKING_DIR}/build/min11/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework "${WORKING_DIR}/build/min11/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/min11/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-output "${WORKING_DIR}/build/min11/ShopLiveSDK_MinVer11.xcframework"

open "${WORKING_DIR}/build/"