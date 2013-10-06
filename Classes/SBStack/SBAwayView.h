/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "SBSlidingAlertDisplay.h"

@class NSDictionary, NSString, NSTimer, SBActivationView, SBAlertImageView, SBAwayChargingView, SBAwayDateView, SBAwayInCallController, SBAwayItemsView, SBNowPlayingArtView, TPBottomButtonBar, TPBottomLockBar, UIImage, UIModalView, UIPushButton;

@interface SBAwayView : SBSlidingAlertDisplay
{
    BOOL _isDimmed;
    BOOL _deferAwayItemFetching;
    BOOL _showingBlockedIndicator;
    BOOL _hasTelephony;
    BOOL _wasShowingAlertAtDismiss;
    SBAwayChargingView *_chargingView;
    SBAwayDateView *_dateView;
    SBNowPlayingArtView *_albumArtView;
    SBAwayItemsView *_awayItemsView;
    SBActivationView *_activationView;
    SBAlertImageView *_firewireWarningView;
    NSTimer *_mediaControlsTimer;
    UIImage *_controlsLCDBG;
    UIImage *_priorLCDBG;
    NSDictionary *_nowPlayingInfo;
    UIImage *_nowPlayingArt;
    NSString *_lastTrackArtPath;
    NSTimer *_blockedStatusUpdateTimer;
    UIModalView *_alertSheet;
    SBAwayInCallController *_inCallController;
    TPBottomLockBar *_lockBar;
    TPBottomButtonBar *_cancelSyncBar;
    UIPushButton *_infoButton;
}

+ (id)createBottomBarForInstance:(id)fp8;
+ (id)lockLabels:(BOOL)fp8 fontSize:(float *)fp12;
- (void)_clearBlockedStatusUpdateTimer;
- (id)initWithFrame:(struct CGRect)fp8;
- (void)postLockCompletedNotification:(BOOL)fp8;
- (void)dealloc;
- (void)_postLockCompletedNotification;
- (void)finishedAnimatingIn;
- (void)dismiss;
- (void)setBottomLockBar:(id)fp8;
- (BOOL)shouldAnimateIn;
- (void)startAnimations;
- (void)stopAnimations;
- (void)showInfoButton;
- (void)hideInfoButton;
- (void)setLockoutUIVisible:(BOOL)fp8 mode:(int)fp12;
- (void)updateUIForRestorationState:(int)fp8;
- (void)updateUIForResetState:(int)fp8;
- (void)addFirewireWarningView;
- (void)removeFirewireWarningView;
- (void)updateInterface;
- (void)setMiddleContentAlpha:(float)fp8;
- (void)setDimmed:(BOOL)fp8;
- (BOOL)dimmed;
- (void)setDrawsBlackBackground:(BOOL)fp8;
- (void)lockBarUnlocked:(id)fp8;
- (void)lockBarStartedTracking:(id)fp8;
- (void)lockBarStoppedTracking:(id)fp8;
- (void)updateLockBarLabel;
- (BOOL)shouldShowBlockedRedStatus;
- (void)_updateBlockedStatusLabel;
- (void)showBlockedStatus;
- (void)removeBlockedStatus;
- (void)_updateBlockedStatus;
- (id)dateView;
- (void)removeDateView;
- (void)addDateView;
- (id)inCallController;
- (BOOL)shouldShowInCallInfo;
- (void)updateInCallInfo;
- (void)_positionAwayItemsView;
- (void)hideAwayItems;
- (void)showAwayItems;
- (BOOL)hasAwayItems;
- (void)setShowingDeviceLock:(BOOL)fp8 duration:(float)fp12;
- (void)showAlertSheet:(id)fp8;
- (void)removeAlertSheet;
- (void)slideAlertSheetOut:(BOOL)fp8 direction:(BOOL)fp12 duration:(float)fp16;
- (void)_batteryStatusChanged:(id)fp8;
- (id)chargingView;
- (void)addChargingView;
- (void)hideChargingView;
- (void)clearMediaControlsTimer;
- (void)restartMediaControlsTimer;
- (void)hideMediaControls;
- (void)showMediaControls;
- (void)toggleMediaControls;
- (BOOL)isShowingMediaControls;
- (void)showSyncingBottomBar:(BOOL)fp8;
- (void)hideSyncingBottomBar:(BOOL)fp8;
- (void)hideNowPlaying;
- (id)nowPlayingArtView;
- (void)musicPlayerDied:(id)fp8;
- (void)updateNowPlayingInfo:(id)fp8;
- (BOOL)updateNowPlayingArt;
- (void)handleRequestedAlbumArtBytes:(char *)fp8 length:(unsigned int)fp12;
- (void)animateToShowingDeviceLock:(BOOL)fp8;

@end

