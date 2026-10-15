package com.liskovsoft.smartyoutubetv2.tv.ui.accountpicker;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.liskovsoft.mediaserviceinterfaces.SignInService;
import com.liskovsoft.mediaserviceinterfaces.oauth.Account;
import com.liskovsoft.smartyoutubetv2.common.app.presenters.BrowsePresenter;
import com.liskovsoft.smartyoutubetv2.common.app.presenters.dialogs.AccountSelectionPresenter;
import com.liskovsoft.smartyoutubetv2.common.app.views.AccountPickerView;
import com.liskovsoft.smartyoutubetv2.common.app.views.BrowseView;
import com.liskovsoft.smartyoutubetv2.common.app.views.SignInView;
import com.liskovsoft.smartyoutubetv2.common.app.views.ViewManager;
import com.liskovsoft.smartyoutubetv2.tv.R;
import com.liskovsoft.smartyoutubetv2.tv.ui.common.LeanbackActivity;
import com.liskovsoft.youtubeapi.service.YouTubeServiceManager;

import java.util.List;

public class AccountPickerActivity extends LeanbackActivity implements AccountPickerView {
    private HorizontalScrollView mProfilesScroll;
    private LinearLayout mProfilesContainer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_account_picker);

        mProfilesScroll = findViewById(R.id.profiles_scroll);
        mProfilesContainer = findViewById(R.id.profiles_container);

        loadAndDisplayProfiles();
    }

    private void loadAndDisplayProfiles() {
        mProfilesContainer.removeAllViews();

        SignInService signInService = YouTubeServiceManager.instance().getSignInService();
        List<Account> accounts = signInService != null ? signInService.getAccounts() : null;

        LayoutInflater inflater = LayoutInflater.from(this);
        View initialFocusView = null;

        // 1. User Accounts
        if (accounts != null && !accounts.isEmpty()) {
            for (Account account : accounts) {
                View card = inflater.inflate(R.layout.item_profile_card, mProfilesContainer, false);
                FrameLayout avatarRing = card.findViewById(R.id.avatar_ring);
                ImageView avatarImage = card.findViewById(R.id.avatar_image);
                TextView nameText = card.findViewById(R.id.profile_name);
                TextView subtitleText = card.findViewById(R.id.profile_subtitle);

                nameText.setText(account.getName());

                if (account.getEmail() != null && !account.getEmail().isEmpty()) {
                    subtitleText.setText(account.getEmail());
                    subtitleText.setVisibility(View.VISIBLE);
                }

                String avatarUrl = account.getAvatarImageUrl();
                if (avatarUrl != null && !avatarUrl.isEmpty()) {
                    Glide.with(this)
                            .load(avatarUrl)
                            .circleCrop()
                            .placeholder(R.drawable.ic_profile_default)
                            .error(R.drawable.ic_profile_default)
                            .into(avatarImage);
                } else {
                    avatarImage.setImageResource(R.drawable.ic_profile_default);
                }

                card.setOnClickListener(v -> {
                    AccountSelectionPresenter.instance(this).selectAccount(account);
                    proceedToBrowse();
                });

                setupFocusAnimation(card, avatarRing, nameText);

                if (account.isSelected()) {
                    initialFocusView = card;
                }

                mProfilesContainer.addView(card);
            }
        }

        // 2. Guest Profile Card
        View guestCard = inflater.inflate(R.layout.item_profile_card, mProfilesContainer, false);
        FrameLayout guestRing = guestCard.findViewById(R.id.avatar_ring);
        ImageView guestImage = guestCard.findViewById(R.id.avatar_image);
        TextView guestName = guestCard.findViewById(R.id.profile_name);
        TextView guestSubtitle = guestCard.findViewById(R.id.profile_subtitle);

        guestImage.setImageResource(R.drawable.ic_profile_guest);
        guestName.setText(R.string.account_picker_guest);
        guestSubtitle.setText(R.string.account_picker_guest_desc);
        guestSubtitle.setVisibility(View.VISIBLE);

        guestCard.setOnClickListener(v -> {
            AccountSelectionPresenter.instance(this).selectAccount(null);
            proceedToBrowse();
        });

        setupFocusAnimation(guestCard, guestRing, guestName);

        if (initialFocusView == null && (accounts == null || accounts.isEmpty() || signInService == null || signInService.getSelectedAccount() == null)) {
            initialFocusView = guestCard;
        }

        mProfilesContainer.addView(guestCard);

        // 3. Add Account Card
        View addCard = inflater.inflate(R.layout.item_profile_card, mProfilesContainer, false);
        FrameLayout addRing = addCard.findViewById(R.id.avatar_ring);
        ImageView addImage = addCard.findViewById(R.id.avatar_image);
        TextView addName = addCard.findViewById(R.id.profile_name);
        TextView addSubtitle = addCard.findViewById(R.id.profile_subtitle);

        addImage.setImageResource(R.drawable.ic_profile_add);
        addName.setText(R.string.account_picker_add);
        addSubtitle.setText(R.string.account_picker_add_desc);
        addSubtitle.setVisibility(View.VISIBLE);

        addCard.setOnClickListener(v -> {
            ViewManager.instance(this).startView(SignInView.class);
            finish();
        });

        setupFocusAnimation(addCard, addRing, addName);
        mProfilesContainer.addView(addCard);

        // Request initial focus
        final View toFocus = initialFocusView != null ? initialFocusView : mProfilesContainer.getChildAt(0);
        if (toFocus != null) {
            toFocus.post(() -> {
                toFocus.requestFocus();
                toFocus.setSelected(true);
            });
        }
    }

    private void setupFocusAnimation(View card, View avatarRing, TextView nameText) {
        card.setOnFocusChangeListener((v, hasFocus) -> {
            float scale = hasFocus ? 1.15f : 1.0f;
            v.animate()
                    .scaleX(scale)
                    .scaleY(scale)
                    .setDuration(180)
                    .start();

            avatarRing.setSelected(hasFocus);
            nameText.setTextColor(hasFocus ? Color.WHITE : Color.parseColor("#B0B3C0"));

            if (hasFocus) {
                int scrollX = v.getLeft() - (mProfilesScroll.getWidth() - v.getWidth()) / 2;
                mProfilesScroll.smoothScrollTo(Math.max(0, scrollX), 0);
            }
        });
    }

    private void proceedToBrowse() {
        ViewManager.instance(this).startView(BrowseView.class);
        finish();
    }

    @Override
    public void onBackPressed() {
        // If Browse is already running (opened from menu/in-app), return to Browse.
        // If booted directly on startup, exit to TV launcher.
        if (BrowsePresenter.instance(this).getView() != null) {
            super.onBackPressed();
        } else {
            moveTaskToBack(true);
        }
    }

    @Override
    public void finishView() {
        finish();
    }
}
