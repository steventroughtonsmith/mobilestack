//
//  StackContentView.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 28/07/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

@class SBStackIcon;

#import "SGridView.h"
#if STACK_3
#import <objc/runtime.h>
//#import "SBStackIcon.h"

@interface SBStackIcon : UIView
{
	
}

-(CGFloat)stackPosition;

@end


#else
#import "MobileStack.h"

#endif

UIImage *tl;
UIImage *tm;
UIImage *tr;
UIImage *l ;
UIImage *c ;
UIImage *r ;
UIImage *bl;
UIImage *bm;
UIImage *br;
UIImage *bt;

static BOOL setup = NO;

@implementation SGridView

- (id) initWithFrame:(CGRect)r
{
	self = [super initWithFrame:r];
	if (self != nil) {
		
		class_setSuperclass( NSClassFromString(@"SGridView"),  NSClassFromString(@"SBIconList"));

		
	}
	return self;
}


-(void)setup
{
	tl = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-tl.png"] retain];
	tm = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-tm.png"] retain];
	tr = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-tr.png"] retain];
	
	l = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-l.png"] retain];
	c = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-c.png"] retain];
	r = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-r.png"] retain];
	
	bl = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-bl.png"] retain];
	bm = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-bm.png"] retain];
	br = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-br.png"] retain];
	
	bt = [[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stackbackground-bt.png"] retain];
	
	setup = YES;
}

-(BOOL)isOpaque
{
	return NO;
}

/* http://phonedev.tumblr.com/post/10385140 */


- (void)drawRect:(CGRect)rect;
{
	if (!setup)
		[self setup];
	
	CGFloat deltaX = -18;
	
#if STACK_3
	CGFloat heightDelta = -85;
#else
	CGFloat heightDelta = -60;

#endif
	
	[tl drawInRect:CGRectMake(deltaX,0,40,40) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	[tm drawInRect:CGRectMake(deltaX+40,0,rect.size.width-80+(-deltaX*2),40) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	[tr drawInRect:CGRectMake(-deltaX+rect.size.width-40,0,40,40) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	
	[l drawInRect:CGRectMake(deltaX+0,40,40,rect.size.height-80+heightDelta) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	[c drawInRect:CGRectMake(deltaX+40,40,rect.size.width-80+(-deltaX*2),rect.size.height-80+heightDelta) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	[r drawInRect:CGRectMake(-deltaX+rect.size.width-40,40,40,rect.size.height-80+heightDelta) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	
	[bl drawInRect:CGRectMake(deltaX+0,rect.size.height-40+heightDelta,40,40) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	[bm drawInRect:CGRectMake(deltaX+40,rect.size.height-40+heightDelta,rect.size.width-80+(-deltaX*2),40) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	[br drawInRect:CGRectMake(-deltaX+rect.size.width-40,rect.size.height-40+heightDelta,40,40) blendMode: kCGBlendModeDestinationOver alpha:1.0];
	
#if !STACK_3

	CGFloat triangleX = [[MobileStack sharedInstance] stackPosition]+5;
#else
	CGFloat triangleX = [[SBStackIcon sharedInstance] stackPosition]+5;

#endif
	
	[[UIColor clearColor] set];
	UIRectFill(CGRectMake(triangleX, rect.size.height-40+heightDelta, 45, 40));
	
	[bt drawInRect:CGRectMake(triangleX, rect.size.height-40+heightDelta, 45, 40)  blendMode:kCGBlendModeDestinationOver alpha:1.0];
	
	
}

-(void)dealloc
{	
	[tl release];
	[tm release];
	[tr release];
	[l release];
	[c release];
	[r release];
	[bl release];
	[bm release];
	[super dealloc];
}
//	[brrect = CGRectInset(rect, 7, 20);
//	rect.size.height -= 60;
//		
//	UIBezierPath *path = [UIBezierPath roundedRectBezierPath:rect withRoundedCorners:kUIBezierPathAllCorners withCornerRadius:10];
//	
//	[path setLineWidth:4.0];
//
//	[[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] set];
//	
//	[path fill];
//	
//	CGFloat deltaX = [[MobileStack sharedInstance] stackPosition];
//	
//	UIBezierPath *arrow = [UIBezierPath bezierPath];
//	
//	[arrow moveToPoint:CGPointMake(deltaX+13, rect.size.height+20)];
//	[arrow lineToPoint:CGPointMake(deltaX+28, rect.size.height+20+15)];
//	[arrow lineToPoint:CGPointMake(deltaX+43, rect.size.height+20)];
//	[arrow closePath];
//	
//	[arrow fill];	




@end