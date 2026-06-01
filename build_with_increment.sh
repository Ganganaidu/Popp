#!/bin/bash

# --- Start of Script ---

echo "🚀 Starting the build and upload process..."

# 1. CLEAN PROJECT CACHES
# ---------------------------------
# This step is crucial to prevent issues from stale or corrupt caches.
echo "🧹 Cleaning project caches..."
flutter clean
cd android
./gradlew clean
cd .. # Navigate back to the project root
echo "✅ Caches cleaned successfully."


# 2. READ AND INCREMENT VERSION
# ---------------------------------
# Extract the version line from pubspec.yaml (ignore comments and blank lines)
version_line=$(grep -E '^version:' pubspec.yaml | head -n 1)

if [ -z "$version_line" ]; then
  echo "❌ Error: Could not find version in pubspec.yaml"
  exit 1
fi

# Extract version name and build number
current_version=$(echo "$version_line" | sed 's/version:[ ]*//')
version_name=${current_version%%+*}
build_number=${current_version##*+}

# Ensure build_number is a number
if ! [[ $build_number =~ ^[0-9]+$ ]]; then
  echo "❌ Error: Build number '$build_number' is not a valid integer."
  exit 1
fi

new_build_number=$((build_number + 1))
new_version="$version_name+$new_build_number"

echo "⬆️  Updating version from $current_version to $new_version"

# Update pubspec.yaml with the new build number
# Note: The -i '' syntax is for macOS. For Linux, use -i without the ''.
sed -i '' "s/^version: .*/version: $new_version/" pubspec.yaml


# 3. BUILD THE FLUTTER APP BUNDLE
# ---------------------------------
echo "📦 Building Flutter App Bundle (Version: $new_version)..."
flutter build appbundle --build-name=$version_name --build-number=$new_build_number

# Check if the build command was successful
if [ $? -ne 0 ]; then
    echo "❌ Error: Flutter build failed. Aborting upload."
    # Optional: Revert the version change in pubspec.yaml on failure
    sed -i '' "s/^version: .*/version: $current_version/" pubspec.yaml
    exit 1
fi

echo "✅ Build successful."


# 4. UPLOAD TO PLAY STORE (INTERNAL TESTING)
# ---------------------------------
echo "📲 Uploading to the Play Store internal track..."

# Navigate to the android directory
cd android

# Run the Gradle publish task
./gradlew publishReleaseBundle --track internal

# Check if the upload was successful
if [ $? -ne 0 ]; then
    echo "❌ Error: Upload to Play Store failed."
    # Navigate back to the root directory
    cd ..
    exit 1
fi

# Navigate back to the root directory
cd ..

echo "✅ Upload successful!"
echo "🎉 Process complete. Version $new_version is now in internal testing."

# --- End of Script ---