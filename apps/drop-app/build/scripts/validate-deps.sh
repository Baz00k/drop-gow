#!/bin/bash
set -e

# Runtime dependency validation script for drop-app Docker image
# Used as a smoke test in CI

FAILED=0

check_binary() {
    local name="$1"
    local binary="$2"
    
    if command -v "$binary" >/dev/null 2>&1; then
        echo "[PASS] Binary: $name ($binary)"
        return 0
    else
        echo "[FAIL] Binary: $name ($binary) - not found in PATH"
        return 1
    fi
}

check_library() {
    local name="$1"
    local library="$2"
    
    if ldconfig -p 2>/dev/null | grep -q "$library"; then
        echo "[PASS] Library: $name ($library)"
        return 0
    else
        echo "[FAIL] Library: $name ($library) - not loadable"
        return 1
    fi
}

check_file() {
    local name="$1"
    local filepath="$2"
    local check_exec="${3:-false}"
    
    if [[ ! -f "$filepath" ]]; then
        echo "[FAIL] File: $name ($filepath) - does not exist"
        return 1
    fi
    
    if [[ "$check_exec" == "true" && ! -x "$filepath" ]]; then
        echo "[FAIL] File: $name ($filepath) - not executable"
        return 1
    fi
    
    echo "[PASS] File: $name ($filepath)"
    return 0
}

echo "=== Runtime Dependency Validation ==="
echo ""

check_binary "drop-app" "drop-app" || FAILED=1

check_library "libayatana-appindicator3" "libayatana-appindicator3" || FAILED=1
check_library "libwebkit2gtk-4.1" "libwebkit2gtk-4.1" || FAILED=1

check_file "startup-app.sh" "/opt/gow/startup-app.sh" "true" || FAILED=1
check_file "launch-comp.sh" "/opt/gow/launch-comp.sh" "true" || FAILED=1
check_file "startup.sh" "/opt/gow/startup.sh" "true" || FAILED=1

echo ""

if [[ $FAILED -eq 0 ]]; then
    echo "All dependency checks passed"
    exit 0
else
    echo "Dependency validation failed"
    exit 1
fi
