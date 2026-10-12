#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

output="${CARGO_TARGET_DIR:-$PWD/target}/macos-smoke"
mkdir -p "$output"
library="$PWD/macos/framework/libreactnativenitrotor.xcframework/macos-arm64_x86_64/libreactnativenitrotor-prebuilt.a"

# Link both architectures against the packaged library, not Cargo's output.
for arch in arm64 x86_64; do
  xcrun --sdk macosx clang++ -std=c++20 -arch "$arch" \
    -mmacosx-version-min=14.0 -Wl,-fatal_warnings -I ios/include \
    scripts/test-macos.cpp ios/src/ffi.rs.cc "$library" \
    -framework Security -framework SystemConfiguration -framework CoreFoundation \
    -lresolv -liconv -o "$output/smoke-$arch"
done

"$output/smoke-$(uname -m)" "$@"
