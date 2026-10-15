#!/usr/bin/env bash
set -euo pipefail

# SmartTube Modern UI & Auto-Update Mod script
# Author: Omc725
# Description: Applies the modern dark/red makeover, startup account picker, and custom update channels.

echo ">>> Applying SmartTube Modern Mod..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

# 1. Update Channel URLs (Beta & Stable)
cat << 'EOF' > common/src/stbeta/res/values/update_urls.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="update_urls">
        <item>https://github.com/Omc725/SmartTube/releases/download/latest/smarttube_beta2.json</item>
    </string-array>
</resources>
EOF

cat << 'EOF' > common/src/ststable/res/values/update_urls.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="update_urls">
        <item>https://github.com/Omc725/SmartTube/releases/download/latest/smarttube_stable2.json</item>
    </string-array>
</resources>
EOF

sed -i 's|https://github.com/yuliskov/SmartTubeNext|https://github.com/Omc725/SmartTube|g' common/src/main/res/values/unlocalized-strings.xml || true
sed -i 's|https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_stable|https://github.com/Omc725/SmartTube/releases/download/latest/smarttube_stable|g' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/StableRestorePresenter.java || true

# 2. Account Selection on Startup (Default to Enabled)
sed -i 's/mIsSelectAccountOnBootEnabled = Helpers.parseBoolean(split, 0, false);/mIsSelectAccountOnBootEnabled = Helpers.parseBoolean(split, 0, true);/g' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/prefs/AccountsData.java

# 3. Account Selection Presenter Enhancements (Show on startup when accounts exist, add Guest and Add Account buttons)
if ! grep -q "import com.liskovsoft.smartyoutubetv2.common.app.presenters.YTSignInPresenter;" common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/AccountSelectionPresenter.java; then
    sed -i '/import com.liskovsoft.smartyoutubetv2.common.app.presenters.settings.AccountSettingsPresenter;/a import com.liskovsoft.smartyoutubetv2.common.app.presenters.YTSignInPresenter;' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/AccountSelectionPresenter.java
fi

sed -i 's/if (accounts.size() <= 1 && !force)/if ((accounts == null || accounts.isEmpty()) \&\& !force)/g' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/AccountSelectionPresenter.java

# 4. Modern Dark Colors
cat << 'EOF' > smarttubetv/src/main/res/values/colors.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- MOD: Focused player button color (default: #66EEEEEE, new: #E8FFFFFF) -->
    <color name="lb_control_button_color">#86EEEEEE</color>

    <!-- Common colors -->
    <color name="default_background_gradient_start">#0a0b0e</color>
    <color name="default_background_gradient_end">#14161f</color>
    <color name="fastlane_background">#E50914</color>
    <color name="fastlane_background_dark">#12131a</color>
    <color name="default_light_grey">#343434</color>
    <color name="search_opaque">#E50914</color>
    <color name="search_opaque_yellow">#ffaa3f</color>

    <!-- Card view colors -->
    <color name="card_selected_background_white">#262938</color>
    <color name="card_selected_background_white_grey">#262938</color>
    <color name="card_selected_background_yellow">#ffaa3f</color>
    <color name="card_selected_background_grey">#262938</color>
    <color name="card_selected_text_black">#FFFFFF</color>
    <color name="card_selected_text_grey">#FFFFFF</color>
    <color name="card_default_background">#151722</color>
    <color name="card_default_background_dark">#151722</color>
    <color name="card_default_text">#FFFFFF</color>

    <!-- Browse fragment colors -->
    <color name="shelf_background">#0f1016</color>
    <color name="shelf_background_dark">#0a0b0e</color>
    <color name="icon_background">#2b2e3d</color>
    <color name="icon_alt_background">#1c1e28</color>
    <color name="player_background">#FF000000</color>

    <!-- Dark color scheme -->
    <color name="scheme_grey_background">#0f1016</color>
    <color name="scheme_grey_background_dark">#0a0b0e</color>
    <color name="scheme_grey_shelf_background_dark">#0a0b0e</color>
    <color name="scheme_grey_card_background_dark">#151722</color>

    <!-- Red color scheme -->
    <color name="scheme_red_background">#0f1016</color>
    <color name="scheme_red_background_dark">#1c0f12</color>
    <color name="scheme_red_shelf_background_dark">#0a0b0e</color>
    <color name="scheme_red_card_background_dark">#1e1417</color>

    <!-- Blue color scheme -->
    <color name="scheme_blue_background">#33B5E5</color>
    <color name="scheme_blue_background_dark">#207EA1</color>

    <!-- Vineyard -->
    <color name="black_87pc">#77000000</color>
    <color name="primary_dark">#12131a</color>
    <color name="primary_light">#262938</color>
    <color name="primary">#E50914</color>
    <color name="white_87pc">#DDFFFFFF</color>

    <!-- Tooltip mod: extracted private values -->
    <color name="tooltip_background_dark_mod">#e61f222e</color>
    <color name="tooltip_background_light_mod">#e6FFFFFF</color>
    <color name="foreground_material_dark_mod">@android:color/white</color>
    <color name="foreground_material_light_mod">@android:color/black</color>

    <!-- Default Orb buttons colors: search, accounts, search settings etc -->
    <color name="orb_color">#262938</color>
    <color name="orb_bright_color">#E50914</color>
    <color name="orb_icon_color">@color/white</color>

    <!-- Search page mic button color -->
    <color name="lb_speech_orb_not_recording">@color/orb_color</color>
    <color name="lb_speech_orb_not_recording_pulsed">@color/orb_bright_color</color>
    <color name="lb_speech_orb_not_recording_icon">@color/orb_icon_color</color>
</resources>
EOF

# 5. Leanback 12dp Rounded Corners
sed -i 's/<dimen name="lb_rounded_rect_corner_radius">2dp<\/dimen>/<dimen name="lb_rounded_rect_corner_radius">12dp<\/dimen>/g' leanback-1.0.0/src/main/res/values/values.xml
sed -i 's/<dimen name="lb_action_button_corner_radius">2dp<\/dimen>/<dimen name="lb_action_button_corner_radius">10dp<\/dimen>/g' leanback-1.0.0/src/main/res/values/values.xml

echo ">>> SmartTube Modern Mod applied successfully!"
