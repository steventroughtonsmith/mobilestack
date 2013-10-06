//
//  SBStackIcon.h
//  MobileStack
//
//  Created by Steven on 23/06/2009.
//  Copyright 2009 Steven Troughton-Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SBIcon.h>
#import <SBUIController.h>
#import <SBIconController.h>
#import <SBIconList.h>
#import <SBStatusBarController.h>

#import <SBApplicationController.h>
#import <SBApplication.h>
#import <QuartzCore/QuartzCore.h>

#import "MobileStackButton.h"
#import "SGridView.h"
#import "MobileStackGlobal.h"


@class NSTimer, SBIconBadge, SBIconImageView, SBIconLabel, UIImageView, UIPushButton;

@interface SBStackIcon : UIControl {
	
	SBIconImageView *_image;
    UIImageView *_reflection;
    UIView *_grayFilterView;
    SBIconBadge *_badge;
    id _badgeNumberOrString;
    SBIconLabel *_label;
    UIPushButton *_closeBox;
    BOOL _isShowingImages:1;
    BOOL _drawsLabel:1;
    BOOL _isHidden:1;
    BOOL _isRevealable:1;
    BOOL _inDock:1;
    BOOL _isGrabbed:1;
    BOOL _isGrabbing:1;
    BOOL _highlighted:1;
    BOOL _isJittering:1;
    BOOL _allowJitter:1;
    BOOL _touchDownInIcon:1;
    NSTimer *_delayedUnhighlightTimer;
    struct CGPoint _unjitterPoint;
    struct CGPoint _grabPoint;
    NSTimer *_grabTimer;
	
	/* Stack */
	NSMutableDictionary *stackPrefs;
	NSMutableArray *buttonArray;
	NSMutableArray *buttonStoreArray;
	MobileStackButton *toggleStackButton;
	UIWindow *stackWindow;
	UIImageView *poofImageView;
	SGridView *roundrectView;


}

+ (SBStackIcon *) sharedInstance;
-(void)insertSelf;
#pragma mark Housekeeping

-(void)addIconToStack:(SBIcon *)icon;
-(void)addItemToStack:(NSString *)identifier;
- (id) initWithDefaultSize;

#pragma mark Convenience Methods

- (void)openStack:(id) event ;
- (void) closeStack:(id) event ;
- (void) showStack:(id) event;
#pragma mark -
#pragma mark StackCode

-(void)createDefaultButtonStore;
-(void)setupStack;
-(NSMutableDictionary *)initStackPrefs;
-(void)saveStackPrefs;
-(void)refreshStackPrefs;
-(CGRect)stackRect;
-(CGRect)_stackDragRect;

-(void)_setupOpen;
#pragma mark -
#pragma mark Fan View

-(void)_openFanView;
-(void)_closeFanView;
#pragma mark -
#pragma mark Grid View

-(void)_openGridView;
-(void)_closeGridView;
#pragma mark -
-(void)hideStackWindow;
-(CGFloat)stackPosition;
-(void)decideRemoveItemFromStack:(id)sender;
-(void)removeItemFromStack:(id)sender;
-(void)displayPoofAtOrigin:(CGPoint)origin;
-(void)openApp:(id)sender;



@end
