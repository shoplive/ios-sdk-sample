#/bin/bash

WORKING_DIR=$(pwd)

xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/combine/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ShopLiveSDK -archivePath "${WORKING_DIR}/build/combine/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# XCFramework 생성
xcodebuild -create-xcframework \
-framework "${WORKING_DIR}/build/combine/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/combine/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-output "${WORKING_DIR}/build/combine/ShopLiveSDK.xcframework"

xcodebuild archive -workspace 'ShopLiveSDK.xcworkspace' -scheme ShopLiveSDKRx -archivePath "${WORKING_DIR}/build/rxswift/ios.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -workspace 'ShopLiveSDK.xcworkspace' -scheme ShopLiveSDKRx -archivePath "${WORKING_DIR}/build/rxswift/ios_sim.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework "${WORKING_DIR}/build/rxswift/ios.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-framework "${WORKING_DIR}/build/rxswift/ios_sim.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework" \
-output "${WORKING_DIR}/build/rxswift/ShopLiveSDK.xcframework"

open "${WORKING_DIR}"