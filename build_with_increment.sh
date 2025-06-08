#!/bin/bash

# Extract the version line from pubspec.yaml (ignore comments and blank lines)
version_line=$(grep -E '^version:' pubspec.yaml | head -n 1)

if [ -z "$version_line" ]; then
  echo "Error: Could not find version in pubspec.yaml"
  exit 1
fi

# Extract version name and build number
current_version=$(echo "$version_line" | sed 's/version:[ ]*//')
version_name=${current_version%%+*}
build_number=${current_version##*+}

# Ensure build_number is a number
if ! [[ $build_number =~ ^[0-9]+$ ]]; then
  echo "Error: Build number is not a valid integer."
  exit 1
fi

new_build_number=$((build_number + 1))

# Update pubspec.yaml with the new build number
sed -i '' "s/^version: .*/version: $version_name+$new_build_number/" pubspec.yaml

# Run build
flutter build appbundle --build-name=$version_name --build-number=$new_build_number
