//
//  StackButton.h
//  MobileStack
//
//  Created by Steven Troughton-Smith on 28/07/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SBApplication.h>
#import <SBApplicationIcon.h>
#import <SBCalendarIconContentsView.h>
#import "MobileStackGlue.h"
#import "MobileStackGlobal.h"

@interface MobileStackButton : UIButton {
	//id representedObject;
	SBApplication *_app;
	UILabel *_label;
	
#if	SHADOW_ENABLED
	UIImageView *_shadow;
#endif
}

//@property (retain) id representedObject;
@property (retain) SBApplication *_app;

#if SHADOW_ENABLED
@property (readonly) UIImageView *_shadow;
#endif

-(void)setApplication:(SBApplication *)app;
-(NSString *)representedDisplayIdentifier;

-(void)showLabel;
-(void)hideLabel;
-(void)initLabel;


@end
