#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Craby currently packages only Android and iOS. Build the same Rust/C++
# bridge for Darwin, keeping its output separate from Craby's iOS framework.
export MACOSX_DEPLOYMENT_TARGET=14.0
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
export ac_cv_func_pipe2=no
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$PWD/target}"
mkdir -p "$CARGO_TARGET_DIR"
CARGO_TARGET_DIR="$(cd "$CARGO_TARGET_DIR" && pwd)"

rustup target add aarch64-apple-darwin x86_64-apple-darwin
for target in aarch64-apple-darwin x86_64-apple-darwin; do
  cargo build --locked --release --package react_native_nitro_tor --target "$target"
done

# Keep the -prebuilt suffix: libreactnativenitrotor.a collides with CocoaPods'
# libReactNativeNitroTor.a on case-insensitive macOS filesystems.
output="$CARGO_TARGET_DIR/macos-universal"
mkdir -p "$output"
xcrun lipo -create \
  "$CARGO_TARGET_DIR/aarch64-apple-darwin/release/libreactnativenitrotor.a" \
  "$CARGO_TARGET_DIR/x86_64-apple-darwin/release/libreactnativenitrotor.a" \
  -output "$output/libreactnativenitrotor-prebuilt.a"
xcrun strip -x -S "$output/libreactnativenitrotor-prebuilt.a"

framework="$PWD/macos/framework/libreactnativenitrotor.xcframework"
rm -rf "$framework"
xcodebuild -create-xcframework \
  -library "$output/libreactnativenitrotor-prebuilt.a" \
  -output "$framework"
