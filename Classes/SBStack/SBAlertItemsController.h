/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "NSObject.h"

@class NSMutableArray, NSTimer;

@interface SBAlertItemsController : NSObject
{
    NSMutableArray *_lockedAlertItems;
    NSMutableArray *_unlockedAlertItems;
    NSTimer *_autoDismissTimer;
}

+ (id)sharedInstance;
- (id)init;
- (void)dealloc;
- (void)convertAnimatingUnlockedAlertsToLockedAlerts;
- (void)deactivateAllAlertItems;
- (void)resetAutoDismissTimer;
- (void)activateAlertItem:(id)fp8;
- (void)_deactivateAlertItem:(id)fp8 reason:(int)fp12;
- (void)deactivateAlertItem:(id)fp8;
- (void)deactivateAlertItem:(id)fp8 reason:(int)fp12;
- (void)deactivateAlertItemsUsingSelector:(SEL)fp8 reason:(int)fp12;
- (void)autoDismissAlertItem:(id)fp8;
- (BOOL)isShowingAlertOfClass:(Class)fp8;
- (BOOL)isShowingAlert:(id)fp8;
- (BOOL)isShowingAlerts;
- (id)visibleAlertItem;
- (BOOL)deactivateAlertForMenuClick;
- (id)deactivateAlertItemsForLock;
- (BOOL)dontLockOverAlertItems;

@end

