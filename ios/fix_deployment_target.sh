#!/bin/bash

echo "Fixing iOS deployment target to 15.0"

# Fix AppFrameworkInfo.plist
/usr/libexec/PlistBuddy -c "Set :MinimumOSVersion 15.0" ios/Flutter/AppFrameworkInfo.plist

# Fix all xcconfig files
find ios/Flutter -name "*.xcconfig" -exec sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 13.0/IPHONEOS_DEPLOYMENT_TARGET = 15.0/g' {} \;

# Fix project.pbxproj
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 13\.0;/IPHONEOS_DEPLOYMENT_TARGET = 15.0;/g' ios/Runner.xcodeproj/project.pbxproj
sed -i '' 's/13\.0/15.0/g' ios/Runner.xcodeproj/project.pbxproj

echo "✅ All files updated to iOS 15.0"