#!/usr/bin/env bash
set -euo pipefail

# SmartTube Modern YouTube TV UI & Auto-Update Mod script
# Author: Omc725
# Description: Applies the YouTube for Android TV visual makeover (fullscreen horizontal profile picker,
# capsule pill sidebar items, rounded card focus outlines, sleek badges) and custom update channels.

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

# 3. AccountPickerView Interface
cat << 'EOF' > common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/views/AccountPickerView.java
package com.liskovsoft.smartyoutubetv2.common.app.views;

public interface AccountPickerView {
    void finishView();
}
EOF

# 4. AccountSelectionPresenter -> Start AccountPickerView
if ! grep -q "AccountPickerView.class" common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/AccountSelectionPresenter.java; then
    sed -i '/public void show(boolean force) {/,/GlideIconFetcher/{
        s|GlideIconFetcher.*|getViewManager().startView(com.liskovsoft.smartyoutubetv2.common.app.views.AccountPickerView.class);|
    }' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/AccountSelectionPresenter.java || true
    sed -i 's/MediaServiceManager.instance().loadAccounts(this::nextAccountOrDialog);/show(true);/g' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/dialogs/AccountSelectionPresenter.java || true
fi

# 5. SplashPresenter: Launch AccountPickerView directly on boot if enabled
if ! grep -q "AccountPickerView.class" common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/SplashPresenter.java; then
    sed -i 's/viewManager.startDefaultView();/if (AccountsData.instance(getContext()).isSelectAccountOnBootEnabled() \&\& !IntentExtractor.hasData(intent)) {\n                viewManager.startView(com.liskovsoft.smartyoutubetv2.common.app.views.AccountPickerView.class);\n            } else {\n                viewManager.startDefaultView();\n            }/g' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/SplashPresenter.java || true
    sed -i 's/AccountSelectionPresenter.instance(getContext()).show();/if (getViewManager().getTopView() != com.liskovsoft.smartyoutubetv2.common.app.views.AccountPickerView.class) {\n            AccountSelectionPresenter.instance(getContext()).show();\n        }/g' common/src/main/java/com/liskovsoft/smartyoutubetv2/common/app/presenters/SplashPresenter.java || true
fi

# 6. Strings for Profile Picker
if ! grep -q "account_picker_title" common/src/main/res/values/strings.xml; then
    sed -i '/<\/resources>/i \    <string name="account_picker_title">Who\\'\''s watching?</string>\n    <string name="account_picker_subtitle">Select a profile to continue</string>\n    <string name="account_picker_guest">Guest</string>\n    <string name="account_picker_guest_desc">Signed out</string>\n    <string name="account_picker_add">Add Account</string>\n    <string name="account_picker_add_desc">Sign in with new account</string>' common/src/main/res/values/strings.xml
fi

if ! grep -q "account_picker_title" common/src/main/res/values-tr/strings.xml; then
    sed -i '/<\/resources>/i \    <string name="account_picker_title">Kim izliyor?</string>\n    <string name="account_picker_subtitle">Devam etmek için bir profil seçin</string>\n    <string name="account_picker_guest">Misafir</string>\n    <string name="account_picker_guest_desc">Oturum açılmadı</string>\n    <string name="account_picker_add">Hesap Ekle</string>\n    <string name="account_picker_add_desc">Yeni hesapla oturum aç</string>' common/src/main/res/values-tr/strings.xml
fi

# 7. Colors & Theme
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
    <color name="account_picker_bg">#0A0B0E</color>

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

if ! grep -q "App.Theme.AccountPicker" smarttubetv/src/main/res/values/styles.xml; then
    sed -i '/<style name="App.Theme.Leanback.Preferences.Base"/i \    <style name="App.Theme.AccountPicker" parent="Theme.Leanback">\n        <item name="android:windowBackground">@color/account_picker_bg</item>\n        <item name="android:windowFullscreen">true</item>\n        <item name="android:windowAnimationStyle">@null</item>\n        <item tools:targetApi="19" name="android:windowTranslucentNavigation">true</item>\n        <item tools:targetApi="18" name="android:windowOverscan">true</item>\n        <item name="android:windowContentOverlay">@null</item>\n    </style>' smarttubetv/src/main/res/values/styles.xml
fi

# 8. Manifest Registration
if ! grep -q "AccountPickerActivity" smarttubetv/src/main/AndroidManifest.xml; then
    sed -i '/<activity[[:space:]]*android:name="com.liskovsoft.smartyoutubetv2.tv.ui.browse.BrowseActivity"/i \        <activity\n            android:name="com.liskovsoft.smartyoutubetv2.tv.ui.accountpicker.AccountPickerActivity"\n            android:launchMode="singleInstance"\n            android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation|layoutDirection"\n            android:screenOrientation="unspecified"\n            android:theme="@style/App.Theme.AccountPicker"/>\n' smarttubetv/src/main/AndroidManifest.xml
fi

# 9. MainApplication Registration
if ! grep -q "AccountPickerView.class" smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/ui/main/MainApplication.java; then
    sed -i '/import com.liskovsoft.smartyoutubetv2.common.app.views.AddDeviceView;/i import com.liskovsoft.smartyoutubetv2.common.app.views.AccountPickerView;' smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/ui/main/MainApplication.java
    sed -i '/import com.liskovsoft.smartyoutubetv2.tv.ui.adddevice.AddDeviceActivity;/i import com.liskovsoft.smartyoutubetv2.tv.ui.accountpicker.AccountPickerActivity;' smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/ui/main/MainApplication.java
    sed -i '/viewManager.register(WebBrowserView.class, WebBrowserActivity.class, BrowseActivity.class);/a \        viewManager.register(AccountPickerView.class, AccountPickerActivity.class, BrowseActivity.class);' smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/ui/main/MainApplication.java
fi

# 10. VideoCardPresenter: Focus Outline
if ! grep -q "card_focus_outline" smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/presenter/VideoCardPresenter.java; then
    sed -i 's|//if (VERSION.SDK_INT >= 23 && MainUIData.instance(context).isUiTweakEnabled(MainUIData.UI_TWEAK_ROUNDED_CORNERS)) {|if (VERSION.SDK_INT >= 23) {\n            cardView.setForeground(ContextCompat.getDrawable(context, R.drawable.card_focus_outline));\n        }|g' smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/presenter/VideoCardPresenter.java || true
    sed -i 's|//    cardView.setForeground(ContextCompat.getDrawable(context, R.drawable.lb_card_outline));||g' smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/presenter/VideoCardPresenter.java || true
    sed -i 's|//}||g' smarttubetv/src/main/java/com/liskovsoft/smartyoutubetv2/tv/presenter/VideoCardPresenter.java || true
fi

# 11. Leanback 12dp Rounded Corners
sed -i 's/<dimen name="lb_rounded_rect_corner_radius">2dp<\/dimen>/<dimen name="lb_rounded_rect_corner_radius">12dp<\/dimen>/g' leanback-1.0.0/src/main/res/values/values.xml || true
sed -i 's/<dimen name="lb_action_button_corner_radius">2dp<\/dimen>/<dimen name="lb_action_button_corner_radius">10dp<\/dimen>/g' leanback-1.0.0/src/main/res/values/values.xml || true

echo ">>> SmartTube Modern Mod applied successfully!"
