/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "SBStatusBarContentView.h"

@class UIImageView;

@interface SBStatusBarVPNView : SBStatusBarContentView
{
    UIImageView *_imageView;
    BOOL _setOnce;
    BOOL _showIndicator;
}

- (id)init;
- (void)vpnConnectionChanged;
- (void)setShowsIndicator:(BOOL)fp8;
- (BOOL)showsIndicator;
- (void)setMode:(int)fp8;
- (void)dealloc;

@end

