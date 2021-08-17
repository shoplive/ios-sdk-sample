#/bin/bash

WORKING_DIR=$(pwd)

rm -rf "${WORKING_DIR}/build/*"

xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/catalyst.xcarchive" -destination='generic/platform=macOS,variant=Mac Catalyst' SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# XCFramework 생성
xcodebuild -create-xcframework \
-framework "${WORKING_DIR}/build/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/catalyst.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-output "${WORKING_DIR}/build/ShopLiveSDK.xcframework"

# xcodebuild archive -scheme ShopLiveSDKRx -archivePath "${WORKING_DIR}/build/min11/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
# xcodebuild archive -scheme ShopLiveSDKRx -archivePath "${WORKING_DIR}/build/min11/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# xcodebuild -create-xcframework \
# -framework "${WORKING_DIR}/build/min11/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK_MinVer11.framework" \
# -framework "${WORKING_DIR}/build/min11/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK_MinVer11.framework" \
# -output "${WORKING_DIR}/build/min11/ShopLiveSDK_MinVer11.xcframework"

open "${WORKING_DIR}/build/"