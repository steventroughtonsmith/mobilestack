/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "NSObject.h"

@class NSDictionary, NSTimer;

@interface SBMediaController : NSObject
{
    int _manualVolumeChangeCount;
    NSDictionary *_nowPlayingInfo;
    float _pendingVolumeChange;
    NSTimer *_volumeCommitTimer;
    BOOL _debounceVolumeRepeat;
}

+ (id)sharedInstance;
- (id)init;
- (void)dealloc;
- (void)setNowPlayingInfo:(id)fp8;
- (BOOL)hasTrack;
- (BOOL)isFirstTrack;
- (BOOL)isLastTrack;
- (BOOL)isPlaying;
- (BOOL)isMovie;
- (id)nowPlayingArtist;
- (id)nowPlayingTitle;
- (id)nowPlayingAlbum;
- (BOOL)changeTrack:(int)fp8;
- (BOOL)beginSeek:(int)fp8;
- (BOOL)endSeek:(int)fp8;
- (BOOL)togglePlayPause;
- (float)volume;
- (void)setVolume:(float)fp8;
- (void)_changeVolumeBy:(float)fp8;
- (float)_calcButtonRepeatDelay;
- (void)increaseVolume;
- (void)decreaseVolume;
- (void)cancelVolumeEvent;
- (void)handleVolumeEvent:(struct __GSEvent *)fp8;
- (void)_registerForAVSystemControllerNotifications;
- (void)_unregisterForAVSystemControllerNotifications;
- (void)_serverConnectionDied:(id)fp8;
- (void)musicPlayerDied:(id)fp8;
- (void)_systemVolumeChanged:(id)fp8;
- (void)_cancelPendingVolumeChange;
- (void)_commitVolumeChange:(id)fp8;
- (BOOL)_performIAPCommand:(int)fp8 status:(int)fp12;

@end

