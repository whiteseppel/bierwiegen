#!/usr/bin/env bash
#
# dev-device.sh — drive the Bierwiegen app on a connected Android device/emulator
# for a build → deploy → observe → interact development loop.
#
# The reliable primitives are `screenshot` (full-res PNG you look at) and
# `tap X Y` (device pixel coordinates — screenshots are full resolution, so read
# coordinates straight off the PNG, no scaling). `find`/`dump` are best-effort:
# they read Android's accessibility tree, which a Flutter app only populates when
# its semantics tree is active (e.g. an a11y service is running), so they may be
# sparse — fall back to screenshot + tap when they are.
#
# Config via env vars (all have sensible defaults):
#   BW_ADB     path to adb
#   BW_SERIAL  device serial (auto-detected if exactly one device is attached)
#   BW_PKG     application id
#   BW_OUT     directory for screenshots / dumps
#
# Usage: scripts/dev-device.sh <command> [args]   (run with no args for help)

set -euo pipefail

# --- configuration ------------------------------------------------------------

find_adb() {
  if [[ -n "${BW_ADB:-}" ]]; then echo "$BW_ADB"; return; fi
  for c in "${ANDROID_HOME:-}/platform-tools/adb" \
           "${ANDROID_SDK_ROOT:-}/platform-tools/adb" \
           "$HOME/Library/Android/sdk/platform-tools/adb"; do
    [[ -x "$c" ]] && { echo "$c"; return; }
  done
  command -v adb 2>/dev/null || { echo "adb not found (set BW_ADB)" >&2; exit 1; }
}

ADB="$(find_adb)"
PKG="${BW_PKG:-com.whiteseppel.bierwiegen}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${BW_OUT:-$ROOT/dev-screens}"
APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"

resolve_serial() {
  if [[ -n "${BW_SERIAL:-}" ]]; then echo "$BW_SERIAL"; return; fi
  local list
  list="$("$ADB" devices | awk 'NR>1 && $2=="device" {print $1}')"
  local n; n="$(echo "$list" | grep -c . || true)"
  if [[ "$n" -eq 1 ]]; then echo "$list"
  elif [[ "$n" -eq 0 ]]; then echo "no device attached" >&2; exit 1
  else echo "multiple devices attached; set BW_SERIAL to one of:" >&2; echo "$list" >&2; exit 1
  fi
}

SERIAL="$(resolve_serial)"
a() { "$ADB" -s "$SERIAL" "$@"; }
stamp() { date +%Y%m%d-%H%M%S; }

# --- commands -----------------------------------------------------------------

cmd_build()   { ( cd "$ROOT" && flutter build apk --debug ); }
cmd_install() { a install -r "${1:-$APK}"; }
cmd_launch()  { a shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null; echo "launched $PKG"; }
cmd_stop()    { a shell am force-stop "$PKG"; echo "stopped $PKG"; }
cmd_deploy()  { cmd_build && cmd_install && cmd_launch; }

cmd_screenshot() {
  mkdir -p "$OUT"
  local f="${1:-$OUT/shot-$(stamp).png}"
  a exec-out screencap -p > "$f"
  echo "$f"
}

cmd_tap()   { a shell input tap "$1" "$2"; }
cmd_swipe() { a shell input swipe "$1" "$2" "$3" "$4" "${5:-300}"; }
cmd_text()  { a shell input text "$1"; }        # spaces: use %s or quote carefully
cmd_key()   { a shell input keyevent "$1"; }
cmd_back()  { a shell input keyevent 4; }
cmd_home()  { a shell input keyevent 3; }

cmd_foreground() {
  a shell dumpsys activity activities 2>/dev/null | grep -i "topResumedActivity" | head -1
}

cmd_logcat() { a logcat -d 2>/dev/null | grep -i "flutter\|E/AndroidRuntime\|exception" | tail -"${1:-40}"; }

cmd_dump() {
  mkdir -p "$OUT"
  local f="$OUT/window-$(stamp).xml"
  a shell uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1
  a pull /sdcard/window_dump.xml "$f" >/dev/null 2>&1
  echo "$f"
}

# find "<query>": print elements whose text/desc/id contains <query> (case-insensitive)
# with the center coordinate to tap. Best-effort (see header note).
cmd_find() {
  local xml; xml="$(cmd_dump)"
  python3 - "$xml" "$1" <<'PY'
import sys, xml.etree.ElementTree as ET
path, q = sys.argv[1], sys.argv[2].lower()
root = ET.parse(path).getroot()
hits = 0
for n in root.iter('node'):
    hay = " ".join(n.get(k, "") for k in ("text", "content-desc", "resource-id")).lower()
    if q and q in hay:
        b = n.get("bounds", "")  # [x1,y1][x2,y2]
        nums = [int(x) for x in b.replace("[", " ").replace("]", " ").replace(",", " ").split()]
        if len(nums) == 4:
            cx, cy = (nums[0]+nums[2])//2, (nums[1]+nums[3])//2
            label = n.get("text") or n.get("content-desc") or n.get("resource-id")
            print(f"tap {cx} {cy}   # {label!r}")
            hits += 1
if not hits:
    print(f"no elements matched {q!r} (Flutter semantics may be off — use screenshot+tap)", file=sys.stderr)
PY
}

usage() {
  cat <<EOF
dev-device.sh — drive Bierwiegen on device ($SERIAL, $PKG)

  build                compile the debug APK
  install [apk]        install (default: $APK)
  launch               start the app
  deploy               build + install + launch
  stop                 force-stop the app

  screenshot [file]    capture a full-res PNG (default: dev-screens/shot-<ts>.png)
  tap X Y              tap at device pixel X,Y (read straight off the screenshot)
  swipe X1 Y1 X2 Y2 [ms]
  text "STR"           type text into the focused field
  key CODE | back | home
  foreground           show the currently resumed activity
  logcat [n]           last n flutter/error log lines (default 40)

  dump                 pull the accessibility tree XML (best-effort for Flutter)
  find "QUERY"         print tap coords for elements matching QUERY (best-effort)

Env: BW_ADB BW_SERIAL BW_PKG BW_OUT
EOF
}

# --- dispatch -----------------------------------------------------------------

cmd="${1:-help}"; shift || true
case "$cmd" in
  build|install|launch|deploy|stop|screenshot|tap|swipe|text|key|back|home|foreground|logcat|dump|find)
    "cmd_$cmd" "$@" ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $cmd" >&2; usage; exit 1 ;;
esac
