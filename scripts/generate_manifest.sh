#!/usr/bin/env bash
set -euo pipefail

VERSION_NAME="${1:-32.67}"
VERSION_CODE="${2:-2457}"
UPSTREAM_COMMIT="${3:-HEAD}"
SHORT_SHA="${UPSTREAM_COMMIT:0:7}"
OUTPUT_FILE="${4:-release_assets/smarttube_beta2.json}"

mkdir -p "$(dirname "$OUTPUT_FILE")"

cat << EOF > "$OUTPUT_FILE"
{
    "package": {
        "downloadUrlList": [
            "https://github.com/Omc725/SmartTube/releases/download/latest/smarttube_beta_armeabi-v7a.apk"
        ],
        "downloadUrlList_arm64-v8a": [
            "https://github.com/Omc725/SmartTube/releases/download/latest/smarttube_beta_arm64-v8a.apk"
        ],
        "downloadUrlList_x86": [
            "https://github.com/Omc725/SmartTube/releases/download/latest/smarttube_beta_x86.apk"
        ]
    },
    "${VERSION_NAME}": {
        "versionCode": ${VERSION_CODE},
        "changelog": [
            "Modern UI Makeover & Dark Theme",
            "Startup Account Selection Screen",
            "Synced with upstream SmartTube (${SHORT_SHA})"
        ],
        "changelog_tr": [
            "Modern karanlık arayüz makyajı",
            "Açılışta hesap seçme ekranı",
            "En son SmartTube sürümü ile senkronize edildi (${SHORT_SHA})"
        ]
    }
}
EOF

echo "Generated update manifest at $OUTPUT_FILE for version $VERSION_NAME ($VERSION_CODE)"
