#!/bin/sh

#  uni-framework.sh
#  Travelogue
#
#  Created by Sayantan Chakraborty on 19/01/21.
#  

#Build iOS device archive
xcodebuild archive \
-scheme InteractBrand \
-destination "generic/platform=iOS" \
-archivePath ../output/InteractBrand-iOS \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

#Build iOS simulator archive
xcodebuild archive \
-scheme InteractBrand \
-destination "generic/platform=iOS Simulator" \
-archivePath ../output/InteractBrand-SIM \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

#Create xcframework
xcodebuild -create-xcframework \
-framework ./output/InteractBrand-iOS.xcarchive/Products/Library/Frameworks/InteractBrand.framework \
-framework ./output/InteractBrand-SIM.xcarchive/Products/Library/Frameworks/InteractBrand.framework \
-output ./InteractBrand.xcframework
