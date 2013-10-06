//
//  StackButton.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 28/07/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

#import "MobileStackButton.h"
#import "MobileStack.h"

@implementation MobileStackButton
@synthesize _app;

#if SHADOW_ENABLED
@synthesize _shadow;
#endif

BOOL moving = NO;

-(void)initLabel
{
	NSLog(@"ILABEL: 1");
	_label = [[UILabel alloc] initWithFrame:CGRectMake(-7.0f, self.bounds.size.height+2,self.bounds.size.width+14.0f, 12.0)];
	NSLog(@"ILABEL: 1.5");

	_label.text = [self._app displayName];
	_label.font = [UIFont boldSystemFontOfSize:11.0];
	_label.backgroundColor = [UIColor clearColor];
	_label.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
	NSLog(@"ILABEL: 2");

	_label.shadowColor = [UIColor colorWithWhite:0.3 alpha:1.0];
	_label.shadowOffset = CGSizeMake(0.0, -1.0);
	_label.textAlignment = UITextAlignmentCenter;
	_label.hidden = YES;
	NSLog(@"ILABEL: 3");

	[self addSubview:_label];
	[self bringSubviewToFront:_label];
	[_label release];
	NSLog(@"ILABEL: 4");

}

-(void)showLabelAtRight
{
	_label.hidden = NO;
	_label.frame = CGRectMake(self.bounds.size.width+10, self.bounds.size.height/2-8, 150, 16.0);
	_label.textAlignment = UITextAlignmentLeft;
	_label.font = [UIFont boldSystemFontOfSize:16.0];

	[_label setNeedsDisplay];
}

-(void)showLabel
{
	_label.hidden = NO;
	[_label setNeedsDisplay];
}

-(void)hideLabel
{
	_label.hidden = YES;
	[_label setNeedsDisplay];
}

-(NSString *)representedDisplayIdentifier
{
	return [self._app displayIdentifier];
}

-(NSString *)displayName
{
	return [self._app displayName];

}

#if !STACK_3

#if 1

-(void)mouseUp:(GSEvent *)e
{
	//self.exclusiveTouch = YES;
	
	if ([[MobileStack sharedInstance] isMoving])
	{
		
		
		
		//NSLog(@"touches!!");
		//UITouch *t = [touches anyObject];
		
		
		if ([[MobileStack sharedInstance] stackOpen]) return; 
		[[MobileStack sharedInstance] redisplay];
		moving = NO;
	}
	else {
		
		[super mouseUp:e];
	}
	
	
}

- (void)mouseDragged:(GSEvent *)e
{
	if ([[MobileStack sharedInstance] isMoving])
	{
		[self cancelMouseTracking];
		[[self window] mouseDown:e];
		[[self window] mouseDragged:e];
	}
	else {
		[super mouseDragged:e];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)e
{
	
	if ([[MobileStack sharedInstance] isMoving])
	{
		[self touchesCancelled:touches withEvent:e];
		[[self window] touchesBegan:touches withEvent:e];
		[[self window] touchesMoved:touches withEvent:e];
	}
	else {
		[super touchesMoved:touches withEvent:e];
	}
	
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//self.exclusiveTouch = YES;
	
	if ([[MobileStack sharedInstance] isMoving])
	{
		
	
	
	//NSLog(@"touches!!");
	UITouch *t = [touches anyObject];
	
	
	if ([[MobileStack sharedInstance] stackOpen]) return; 
	[[MobileStack sharedInstance] redisplay];
		moving = NO;
	}
	else {
		
		[super touchesEnded:touches withEvent:event];
	}

	
}
#endif


#endif

-(void)setApplication:(SBApplication *)app
{
	NSLog(@"SA: 1");
	self._app = app;
	
	self.clipsToBounds = NO;
	
	Class SBApplicationIcon = objc_getClass("SBApplicationIcon");
	
	Class SBCalendarIconContentsView = objc_getClass("SBCalendarIconContentsView");

	SBApplicationIcon *_appIcon = [[SBApplicationIcon alloc] initWithApplication:app];
	NSLog(@"SA: 2");

	UIImage *_iconImage = [_appIcon icon] ;
	[_appIcon release];
	
#if SHADOW_ENABLED
	UIImage *_shadowImage = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_shadow.png"] ;
	_shadow = [[UIImageView alloc] initWithImage:_shadowImage];
	_shadow.alpha = 0.0;
	_shadow.userInteractionEnabled = NO;
	
	_shadow.center = self.center;
	//_shadow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin & UIViewAutoresizingFlexibleRightMargin & UIViewAutoresizingFlexibleBottomMargin & UIViewAutoresizingFlexibleTopMargin;
	
	//[self setBackgroundImage:_shadowImage forState:UIControlStateNormal];
	
	[self _setBackground:_shadow forStates:UIControlStateNormal];//insertSubview:_shadow atIndex:0];
	[_shadow release];
#endif
	NSLog(@"SA: 3");

	/* Specific addition for Calendar icon, as it's dynamic */
	
	if ([[app displayIdentifier] isEqualToString:@"com.apple.mobilecal"])
	{
		SBCalendarIconContentsView *_calContents = [[SBCalendarIconContentsView alloc] initWithFrame:self.frame];
		[_calContents setOpaque:NO];
		UIGraphicsBeginImageContext(CGSizeMake([_iconImage size].width, [_iconImage size].height+1));
		
		[_iconImage drawAtPoint:CGPointMake(0,1) blendMode:kCGBlendModeDestinationOver alpha:1.0];
		[_calContents drawRect:CGRectMake(0,1,59,60)];
		//[_calContents release];
		
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		//[_iconImage release];
		[_calContents release];
		
		[self setImage:newImage forState:UIControlStateNormal];
		NSLog(@"SA: 4");

	}
	else
	{		
		UIGraphicsBeginImageContext(CGSizeMake([_iconImage size].width, [_iconImage size].height+1));
		[_iconImage drawAtPoint:CGPointMake(0,1) blendMode:kCGBlendModeDestinationOver alpha:1.0];
		
		UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		//	[self setOpaque:YES];
		//		[self setBackgroundColor:[UIColor blueColor]];
		
		[self setImage:newImage forState:UIControlStateNormal];
		NSLog(@"SA: 5");

	}
	
#if 0//TARGET_IPHONE_SIMULATOR
	
	NSData *data = UIImagePNGRepresentation([_appIcon icon]);
	[data writeToFile:[NSString stringWithFormat:@"/tmp/%@.png", [app displayIdentifier]] atomically:YES];
	
#endif
	
	NSLog(@"about to initLabel");
	[self performSelectorOnMainThread:@selector(initLabel) withObject:nil waitUntilDone:YES];//performSelector:@selector(initLabel) withObject:nil afterDelay:1.0];
}

@end

