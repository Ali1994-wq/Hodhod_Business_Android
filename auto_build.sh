#!/data/data/com.termux/files/usr/bin/bash

set -u

PROJECT="$HOME/Hodhod_Business_Android"
LOG_DIR="$HOME/flutter-sdk-backups"
DATE="$(date '+%Y%m%d_%H%M%S')"
LOG="$LOG_DIR/hodhod-rebuild-$DATE.log"
APK_DEST="$HOME/storage/downloads/Hodhod-Business-Release.apk"

mkdir -p "$LOG_DIR"
mkdir -p "$PROJECT/.tmp"
mkdir -p "$HOME/storage/downloads"

cd "$PROJECT" || exit 1

exec > >(tee -a "$LOG") 2>&1

echo "============================================"
echo " HODHOD BUSINESS CLEAN REBUILD"
echo "============================================"
echo "DATE: $(date)"
echo "PROJECT: $PROJECT"
echo "LOG: $LOG"
echo

echo "============================================"
echo " ENVIRONMENT"
echo "============================================"

export ANDROID_HOME="$HOME/lib/android-sdk-9123335"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PUB_CACHE="$HOME/.pub-cache"
export TMPDIR="$PROJECT/.tmp"

export GRADLE_USER_HOME="$HOME/.gradle"

echo "ANDROID_HOME=$ANDROID_HOME"
echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo "PUB_CACHE=$PUB_CACHE"
echo "TMPDIR=$TMPDIR"
echo "GRADLE_USER_HOME=$GRADLE_USER_HOME"
echo

flutter --version
echo

java -version
echo

echo "============================================"
echo " SDK CHECK"
echo "============================================"

if [ ! -d "$ANDROID_HOME/platforms/android-34" ]; then
    echo "ERROR: Android SDK Platform 34 is missing."
    exit 10
fi

if [ ! -d "$ANDROID_HOME/platforms/android-35" ]; then
    echo "ERROR: Android SDK Platform 35 is missing."
    exit 11
fi

echo "Android Platform 34: OK"
echo "Android Platform 35: OK"
echo

echo "============================================"
echo " CLEAN PROJECT BUILD ARTIFACTS"
echo "============================================"

rm -rf "$PROJECT/build"
rm -rf "$PROJECT/android/app/build"
rm -rf "$PROJECT/android/.gradle"

echo "Project build artifacts removed."
echo "Global Gradle cache preserved."
echo "Pub cache preserved."
echo "Android SDK preserved."
echo "Flutter SDK preserved."
echo

echo "============================================"
echo " FLUTTER PUB GET"
echo "============================================"

if ! flutter pub get; then
    echo
    echo "============================================"
    echo " PUB GET FAILED"
    echo "============================================"
    echo "LOG=$LOG"
    exit 20
fi

echo
echo "PUB_GET_OK"

echo
echo "============================================"
echo " DART ANALYZE"
echo "============================================"

ANALYZE_LOG="$PROJECT/.tmp/analyze-$DATE.log"

flutter analyze --no-pub > "$ANALYZE_LOG" 2>&1
ANALYZE_EXIT=$?

cat "$ANALYZE_LOG"

if [ "$ANALYZE_EXIT" -ne 0 ]; then
    echo
    echo "WARNING: flutter analyze returned exit code $ANALYZE_EXIT"
    echo "Continuing to build so the actual release-build error can be identified."
else
    echo "FLUTTER_ANALYZE_OK"
fi

echo
echo "============================================"
echo " RELEASE APK BUILD"
echo "============================================"

BUILD_LOG="$PROJECT/.tmp/flutter-build-$DATE.log"

flutter build apk \
    --release \
    --no-pub \
    --target=lib/main.dart \
    --verbose \
    > "$BUILD_LOG" 2>&1

BUILD_EXIT=$?

cat "$BUILD_LOG"

echo
echo "BUILD_EXIT_CODE=$BUILD_EXIT"

if [ "$BUILD_EXIT" -ne 0 ]; then

    echo
    echo "============================================"
    echo " BUILD FAILED"
    echo "============================================"

    echo
    echo "========== FIRST IMPORTANT ERRORS =========="

    grep -n -E \
    'Error:|error:|ERROR:|Exception:|FAILURE:|Failed to|Execution failed|Target .* failed|Gradle task .* failed|Process .* finished with non-zero' \
    "$BUILD_LOG" \
    | head -n 80 || true

    echo
    echo "========== END OF BUILD LOG =========="

    tail -n 120 "$BUILD_LOG"

    echo
    echo "============================================"
    echo " BUILD DIAGNOSTICS SAVED"
    echo "============================================"
    echo "BUILD_LOG=$BUILD_LOG"
    echo "FULL_LOG=$LOG"

    exit "$BUILD_EXIT"
fi

echo
echo "============================================"
echo " VERIFY APK"
echo "============================================"

APK_PATH=""

CANDIDATES="
$PROJECT/build/app/outputs/flutter-apk/app-release.apk
$PROJECT/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
$PROJECT/build/app/outputs/apk/release/app-release.apk
"

while IFS= read -r candidate; do
    [ -z "$candidate" ] && continue

    if [ -f "$candidate" ] && [ -s "$candidate" ]; then
        APK_PATH="$candidate"
        break
    fi
done <<EOF2
$CANDIDATES
EOF2

if [ -z "$APK_PATH" ]; then
    APK_PATH="$(find "$PROJECT/build" -type f -name '*.apk' -size +1k 2>/dev/null | head -n 1)"
fi

if [ -z "$APK_PATH" ] || [ ! -f "$APK_PATH" ]; then
    echo "ERROR: Build returned success but no APK was found."
    echo
    echo "APK SEARCH:"
    find "$PROJECT/build" -type f -name '*.apk' -ls 2>/dev/null || true
    echo
    echo "FULL_LOG=$LOG"
    exit 30
fi

APK_SIZE="$(stat -c '%s' "$APK_PATH" 2>/dev/null || echo 0)"

if [ "$APK_SIZE" -le 0 ]; then
    echo "ERROR: APK exists but has invalid size."
    exit 31
fi

echo "APK_PATH=$APK_PATH"
echo "APK_SIZE=$APK_SIZE bytes"

echo
echo "============================================"
echo " APK VALIDATION"
echo "============================================"

if command -v apksigner >/dev/null 2>&1; then
    apksigner verify --verbose "$APK_PATH"
    SIGN_EXIT=$?

    if [ "$SIGN_EXIT" -ne 0 ]; then
        echo "WARNING: APK signature verification failed."
        echo "The APK was built, but signing must be investigated."
    else
        echo "APK_SIGNATURE_VERIFIED"
    fi
else
    echo "apksigner not available; skipping signature validation."
fi

echo
echo "============================================"
echo " COPY APK TO DOWNLOAD"
echo "============================================"

rm -f "$APK_DEST"

cp -f "$APK_PATH" "$APK_DEST"

if [ "$?" -ne 0 ] || [ ! -s "$APK_DEST" ]; then
    echo "ERROR: APK copy failed."
    exit 40
fi

DEST_SIZE="$(stat -c '%s' "$APK_DEST" 2>/dev/null || echo 0)"

if [ "$DEST_SIZE" -ne "$APK_SIZE" ]; then
    echo "ERROR: Copied APK size does not match source."
    echo "SOURCE_SIZE=$APK_SIZE"
    echo "DEST_SIZE=$DEST_SIZE"
    exit 41
fi

echo
echo "============================================"
echo " BUILD SUCCESS"
echo "============================================"
echo "APK_SOURCE=$APK_PATH"
echo "APK_DESTINATION=$APK_DEST"
echo "APK_SIZE=$DEST_SIZE bytes"
echo "BUILD_LOG=$BUILD_LOG"
echo "FULL_LOG=$LOG"
echo
echo "HODHOD_BUSINESS_APK_READY"
echo "============================================"

exit 0
