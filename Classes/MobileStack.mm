
#import <SBUIController.h>
#import <SBIconController.h>
#import <SBIconList.h>
#import <SBApplicationController.h>
#import <SBApplication.h>

#ifndef GRAPHICSSERVICES_H

#import <GraphicsServices.h>
#endif
#import <QuartzCore/QuartzCore.h>

#import "MobileStack.h"
#import "MobileStackGlue.h"

#import <notify.h>


#define STACK_PREFS_PATH @"/User/Library/Preferences/com.steventroughtonsmith.stack.plist"

//extern GSEventRef WKEventGetCurrentEvent(void); 

#define MULTIPLIER (-3)
#define BUTTON_HEIGHT (70.0)

#define DELTA 60.0f


enum {
	StackStandardPosition = 245,
	StackCenterPosition = 131
};

NSTimer *moveTimer;

//#define [self stackPosition] StackStandardPosition

BOOL stackOpen = NO;
BOOL useCurvedStack = YES;
BOOL forceGridView = NO;
BOOL isMoving = NO;

BOOL shouldIgnore = NO;

CGFloat timescale = 0.3f;

static MobileStack *sharedInstance = nil;

@implementation 
 NSObject (StackHackFix)
- (BOOL)isEqualToString:(NSString *)aString
{
	return NO;
}
@end


@implementation MobileStack

@synthesize stackWindow;
@synthesize contentView;

-(BOOL)isMoving 
{
	return isMoving;
}


-(void)setStackPosition:(CGFloat)f
{
	stackPosition = f;
}

-(CGFloat)stackPosition
{	
	[self refreshStackPrefs];
	
	if ([[[stackPrefs valueForKey:@"StackPosition"] class] isEqual:[NSString class]])
	{
		if ([[stackPrefs valueForKey:@"StackPosition"] isEqualToString:@"br"])
			return StackStandardPosition;
		else if ([[stackPrefs valueForKey:@"StackPosition"] isEqualToString:@"center"])
			return StackCenterPosition;
	}
	else
		return [[stackPrefs valueForKey:@"StackPosition"] floatValue];
}

-(CGRect)_stackDragRect
{	
	return CGRectMake([self stackPosition], 480-70, 70, 70);
}

+ (MobileStack *) sharedInstance
{
	if (sharedInstance == nil) 
	{		
		sharedInstance = [[MobileStack alloc] init];
		
		
		
	}
	return sharedInstance;
}

#pragma mark Convenience Methods

- (void)openStack:(id) event 
{
	if (!stackOpen)
		[self showStack:event];
}

- (void) closeStack:(id) event 
{
	if (stackOpen)
	{
		[self showStack:event];
	}
}

-(void)redisplay
{
	CGRect rect = [self stackRect];

	isMoving = NO;
	//[stackWindow setFrame:[UIScreen mainScreen].bounds];
	
	//[contentView setFrame:CGRectMake([self stackPosition], 0, 60.0f, 90.0f)];
	//stackWindow.exclusiveTouch = NO;

	stackWindow.frame = contentView.frame;//CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.size.width, contentView.frame.size.height);//contentView.frame;
	
	
	//[self _setupOpen];
	[self setStackPosition:contentView.frame.origin.x];
	
	[toggleStackButton setFrame:CGRectMake(toggleStackButton.frame.origin.x-7, toggleStackButton.frame.origin.y+1, toggleStackButton.frame.size.width, toggleStackButton.frame.size.height)];

	//[stackWindow setFrame:CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, rect.size.height+75.0f)];

	//self.stackWindow.frame = CGRectMake([self stackPosition], rect.size.height-60.0f, 60.0f, 90.0f);

	{
			
		
		/* Order Stack window front*/
		
		[stackWindow makeKeyAndVisible];

		
		/* Setup reference rect */
		
		//CGRect initialRect = CGRectMake(DELTA, rect.size.height-70, 59.0f, 60.0f);
		
		//[stackWindow setFrame:CGRectMake([self stackPosition]-DELTA, 0.0f, 120.0f, rect.size.height+75.0f)];
		[contentView setFrame:CGRectMake(0, 0, 60.0f, 90.0f)];

		//[contentView setFrame:CGRectMake(0.0f, 0.0f, [stackWindow frame].size.width, [stackWindow frame].size.height)];
		
	}

	//contentView.frame = CGRectMake(0, 0, stackWindow.frame.size.width, stackWindow.frame.size.height);
	//[self _setupOpen];
	//contentView.frame = CGRectMake(DELTA, stackWindow.frame.size.height-70, 59.0f, 60.0f);

	toggleStackButton.enabled = YES;
	stackWindow.exclusiveTouch = NO;
	
	contentView.layer.transform = CATransform3DIdentity;

	[stackPrefs setValue:[NSNumber numberWithFloat:stackPosition] forKey:@"StackPosition"];
	[self saveStackPrefs];
	
	[contentView.layer removeAllAnimations];
	

	
}

-(BOOL)stackOpen
{
	return stackOpen;
}

-(void)startMoveTimer:(id)sender
{
	//shouldIgnore = NO;

	if (!moveTimer)
	{
		moveTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_moveTimerCheck) userInfo:nil repeats:NO] retain];
	}
	
	if (![moveTimer isValid])
	{
		[moveTimer release];
		moveTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_moveTimerCheck) userInfo:nil repeats:NO] retain];

	}
	
	//[self performSelector:@selector(_moveTimerCheck) withObject:nil afterDelay:1.0];
}

-(void)_moveTimerCheck
{
	/*
	if (shouldIgnore) 
	{
		[moveTimer invalidate];
		return;
		
	}*/
	
	if (stackOpen) 
	{
		[moveTimer invalidate];
		return;
	}
	
	//[[stackWindow sendEvent:];//touchesBegan:nil withEvent:nil];
	
	[self startMoving:self];
	
	
	
}

-(void)startMoving:(id)sender
{
	
	if (stackOpen) return;
	
	isMoving = YES;
	
	stackWindow.frame = [UIScreen mainScreen].bounds;
	//[stackWindow setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-80.0f, 320.0f, 90.0f)];
	stackWindow.exclusiveTouch = YES;
	//[stackWindow makeKeyAndVisible];
	
	[self closeStack:self];
	
	[contentView setFrame:CGRectMake([self stackPosition], [UIScreen mainScreen].bounds.size.height-80.0f, 60.0f, 90.0f)];
	//stackWindow.backgroundColor = [UIColor blueColor];
	//contentView.backgroundColor = [UIColor redColor];
	
	contentView.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1);
	
	toggleStackButton.enabled = NO;
	
	CABasicAnimation *theAnimation;
	
	theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	theAnimation.duration = 0.15;
	theAnimation.repeatCount = INT_MAX;
	theAnimation.autoreverses = YES;
	theAnimation.fromValue = [NSNumber numberWithFloat:M_PI/180*2];
	theAnimation.toValue = [NSNumber numberWithFloat:-M_PI/180*2];
	
	[contentView.layer addAnimation:theAnimation forKey:@"stackMovableAnimation"];
	//stackWindow.layer.anchorPoint = CGPointMake(0.1, 0.9);
	
	//WKEventGetCurrentEvent();
	
	// GSEvent e = [[UIApplication sharedApplication] _event];
	
	/*if ([[UIApplication sharedApplication] _isTouchEvent:e])
	 {
	 NSLog(@"tcouh");
	 }*/
	
	//CGRect rect = GSEventGetLocationInWindow(e);
	
	//NSLog(@"pount = %f", e.avgX);
	
	//CGPoint point = contentView.frame.origin;
	
	//[contentView setFrame:CGRectMake(point.x-1, stackWindow.frame.origin.y, stackWindow.frame.size.width, stackWindow.frame.size.height)];
	
}

#pragma mark -
#pragma mark Stack Animation Main Layout

-(CGRect)stackRect
{
	/*
	 Resize Stack window height to match screen height to make room for animations and button targets */
	
	CGRect rect = [UIScreen mainScreen].applicationFrame;
	
	rect.origin.y = [UIScreen mainScreen].applicationFrame.origin.y-1;
	rect.size.height = [UIScreen mainScreen].applicationFrame.size.height;
	
	return rect;
}


-(void)_setupOpen
{
	CGRect rect = [self stackRect];
	
	/* Order Stack window front*/
	
	[stackWindow makeKeyAndVisible];
	
	
	
	/* Setup reference rect */
	
	CGRect initialRect = CGRectMake(DELTA, rect.size.height-70, 59.0f, 60.0f);
	
	/* Place Stack minimization button */
	
	[toggleStackButton setFrame:CGRectMake(DELTA, rect.size.height-60-1, 59.0f, 60.0f)];
	[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button.png"] forState:UIControlStateNormal];
	
	/* Position all buttons on the starting rect */
	
	for (MobileStackButton *currentButton in buttonArray)
	{
		[currentButton setFrame:initialRect];
		currentButton.hidden = NO;
		currentButton.alpha = 1.0;
#if SHADOW_ENABLED
		
		currentButton._shadow.alpha = 1.0;
#endif
	}
	
	stackOpen = YES;
	
	[stackWindow setFrame:CGRectMake([self stackPosition]-DELTA, 0.0f, 120.0f, rect.size.height+75.0f)];
	[contentView setFrame:CGRectMake(0.0f, 0.0f, [stackWindow frame].size.width, [stackWindow frame].size.height)];
	[roundrectView setFrame:[contentView bounds]];
	
	/* Setup initial end rect */
	
	CGRect currentEndRect = initialRect;
}

#pragma mark -
#pragma mark Fan View

-(void)_openFanView
{
	[self _setupOpen];
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	CGRect rect = [self stackRect];
	
	CGRect initialRect = CGRectMake(DELTA, rect.size.height-70, 59.0f, 60.0f);
	CGRect currentEndRect = initialRect;
	
	
	int i ;
	if ([self stackPosition] > 130)
		i = -3;
	else
		i = 3;
	
	int x = 0;
	int delta = 0;
	int m = 0;
	
	for (UIView *currentView in buttonArray)
	{
		currentEndRect.origin.y -= BUTTON_HEIGHT;
		
		if (useCurvedStack && !forceGridView) {
			
			if ([self stackPosition] > 130)
				
				x += ++delta;
			else
				x += --delta;
			
			currentEndRect.origin.x = DELTA + x * MULTIPLIER;
			
			//currentView.transform = CATransform3DMakeRotation(i*M_PI/180, 0,0,0);
			
			//currentView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, i*M_PI/180);
			currentView.transform = CGAffineTransformMakeRotation(i*M_PI/180);
			
			
			if ([self stackPosition] > 130)
				i -= 3;
			else
				i += 3;
		}
		
		[currentView setFrame:currentEndRect];
		
		if (m > 2)
			m++;
		
#if SHADOW_ENABLED
		
		[[currentView _shadow] setCenter:CGPointMake(currentEndRect.origin.x+currentEndRect.size.width/2+5*m-1,  [[currentView _shadow] center].y-(5-m))];
		
		[[currentView _shadow] setTransform:CGAffineTransformIdentity];
		
#endif
		m++;
		
		//[[currentView _shadow] setCenter:currentView.center];
		
		//	[[currentView _shadow] setCenter:CGPointMake([[currentView _shadow] center].x+currentEndRect.origin.x+(delta*m), [[currentView _shadow] center].y)];
		
	}
	
	[UIView commitAnimations];	
	
}

-(void)_closeFanView
{
	CGRect rect = [self stackRect];
	
	//_settingsButton.hidden = YES;
	//		_settingsButton.enabled = NO;
	
	/* Disable all controls during animation */
	
	for (MobileStackButton *currentView in buttonArray)
	{
		[currentView setEnabled:NO];
#if SHADOW_ENABLED
		currentView._shadow.alpha = 0.0;
#endif
	}
	
	/* Setup the end frames */
	
	CGRect endRectOther = CGRectMake(0.0f, rect.size.height-80, 59.0f, 60.0f);
	CGRect endRect1 = CGRectMake(5.0f, rect.size.height-75, 59.0f, 60.0f);
	CGRect endRect2 = CGRectMake(0.0f,  rect.size.height-80, 59.0f, 60.0f);
	CGRect endRect3 = CGRectMake(-5.0f, rect.size.height-85, 59.0f, 60.0f);
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	if ([buttonArray count] <= 5 && !forceGridView)
	{
		[stackWindow setFrame:CGRectMake([self stackPosition], 0.0f, 59.0f, rect.size.height)];
		[contentView setFrame:CGRectMake(0, 0, [stackWindow frame].size.width, [stackWindow frame].size.height)];
		[roundrectView setFrame:[contentView bounds]];
		[toggleStackButton setFrame:CGRectMake(0.0f, [stackWindow frame].size.height-[toggleStackButton frame].size.height, 59.0f, 60.0f)];			
	}

	[roundrectView setNeedsDisplay];
	
	/* Set end frame for the three default icons */
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
	{
		
		
		if ([buttonArray count] >= 1)
			
			[[buttonArray objectAtIndex:0] setFrame:endRect1];
		
		if ([buttonArray count] >= 2)
			
			[[buttonArray objectAtIndex:1] setFrame:endRect2];
		
		if ([buttonArray count] >= 3)
			
			[[buttonArray objectAtIndex:2] setFrame:endRect3];	
	}
	
	else
	{
		if ([buttonArray count] >= 1)
			
			[[buttonArray objectAtIndex:0] setFrame:endRectOther];
	}
	
	/* Set end frame for any other icons */
	
	int c = 0;
	for (MobileStackButton *currentButton in buttonArray)
	{
		if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
		{
			if (c >= 3)
			{
				[currentButton setFrame:endRectOther];
				currentButton.alpha = 0.0;
			}
		}
		else  if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
		{
			[currentButton setFrame:endRectOther];
			currentButton.alpha = 0.0;
		}
		else
		{
			if (c >= 1)
			{
				[currentButton setFrame:endRectOther];
				currentButton.alpha = 0.0;
			}
		}
		[currentButton hideLabel];
		
		
		c++;
	}
	
#if 0
	if ([buttonArray count] > 5 || forceGridView)	// Grid View! Ergo NO [de]ROTATION
	{
	}
	else							// Rotate icons back!
	{
#endif
		/* Set Item Rotation */
		if (useCurvedStack && !forceGridView)
		{
			int i = 2;
			for (UIView *currentView in buttonArray)
			{
				currentView.transform = CGAffineTransformIdentity;
				
				//[[currentView _shadow] setTransform:CGAffineTransformIdentity];
				//[[currentView _shadow] setCenter:CGPointMake([[currentView _shadow] center].x+i, [[currentView _shadow] center].y)];
				
				
				i=i+2;
			}
		}
#if 0
	}
#endif
	
	roundrectView.alpha = 0.0f;
	
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{
		
		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	else
	[toggleStackButton setImage:nil forState:UIControlStateNormal];
	
	
	
	/* ---End Animation Block--- */
	
	[UIView commitAnimations];
	
	self.stackWindow.frame = CGRectMake([self stackPosition], rect.size.height-60.0f-1, 60.0f, 90.0f);
	CGRect initialRect = CGRectMake(0.0f, 0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(5.0f, 10.0f, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(0.0f, 5.0f, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(-5.0f, 0.0f, 59.0f, 60.0f);
	
	/* This bit will fix animations */
	int r = 0;
	for (MobileStackButton *currentButton in buttonArray)
	{
		
		if (r >= 3)
		{
			[currentButton setFrame:initialRect];
			
			
		}
		r++;
	}
	
	if ([buttonArray count] >= 1)
		[[buttonArray objectAtIndex:0] setFrame:initialRect3];
	
	if ([buttonArray count] >= 2)
		[[buttonArray objectAtIndex:1] setFrame:initialRect2];
	
	if ([buttonArray count] >= 3)
		[[buttonArray objectAtIndex:2] setFrame:initialRect1];
	
#if SHADOW_ENABLED
	for (MobileStackButton *currentButton in buttonArray)
	{
		[[currentButton _shadow] setCenter:currentButton.center];
	}
#endif		
	[toggleStackButton setFrame:initialRect];
	
	stackOpen = NO;
	
}

#pragma mark -
#pragma mark Grid View

-(void)_openGridView
{
	[self _setupOpen];
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	CGRect rect = [self stackRect];
	
	/* Fill the screen with the grid */
	
	[stackWindow setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height+27)];
	[contentView setFrame:CGRectMake(0, 5, [stackWindow frame].size.width, [stackWindow frame].size.height-5-32)];
	
	[roundrectView setFrame:contentView.frame];
	roundrectView.alpha = 1.0;
	[roundrectView setNeedsDisplay];
	
	[toggleStackButton setFrame:CGRectMake([self stackPosition], [stackWindow frame].size.height-[toggleStackButton frame].size.height-32, [toggleStackButton frame].size.width, [toggleStackButton frame].size.height)];
	
	int x = 17.0; // There's method to my madness! SpringBoard seems to use 17px gaps between icons. Odd number, i agree. Seems to fit.
	int y = 35.0; // Start 10px under the status bar
	
	for (MobileStackButton *currentView in buttonArray)
	{
		[currentView showLabel];
#if SHADOW_ENABLED
		
		currentView._shadow.alpha = 0.0;
#endif
		[currentView setFrame:CGRectMake(x, y, [currentView frame].size.width, [currentView frame].size.height)];
		
		x+=[currentView frame].size.width+17.0;
		
		if (x >= rect.size.width-30)
		{
			y += [currentView frame].size.height + 23.0;
			x = 17.0;
		}
	}	
	
	[UIView commitAnimations];	
	
}

-(void)_closeGridView
{
	CGRect rect = [self stackRect];
	
	//_settingsButton.hidden = YES;
	//		_settingsButton.enabled = NO;
	
	/* Disable all controls during animation */
	
	for (MobileStackButton *currentView in buttonArray)
	{
		[currentView setEnabled:NO];
#if SHADOW_ENABLED
		currentView._shadow.alpha = 0.0;
#endif
	}
	
	/* Setup the end frames */
	
	//[contentView setFrame:CGRectMake([self stackPosition], [UIScreen mainScreen].bounds.size.height-80.0f, 60.0f, 90.0f)];
	
	
	CGRect endRectOther = CGRectMake(0.0f, rect.size.height-80, 59.0f, 60.0f);
	CGRect endRect1 = CGRectMake(5.0f, rect.size.height-75, 59.0f, 60.0f);
	CGRect endRect2 = CGRectMake(0.0f,  rect.size.height-80, 59.0f, 60.0f);
	CGRect endRect3 = CGRectMake(-5.0f, rect.size.height-85, 59.0f, 60.0f);
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	{
		[stackWindow setFrame:CGRectMake([self stackPosition], 0.0f, 59.0f, rect.size.height)];
		[contentView setFrame:CGRectMake(0, 0, [stackWindow frame].size.width, [stackWindow frame].size.height)];
		[toggleStackButton setFrame:CGRectMake(0.0f, [stackWindow frame].size.height-[toggleStackButton frame].size.height, 59.0f, 60.0f)];
		
		endRectOther.origin.x += [self stackPosition];
		endRect1.origin.x += [self stackPosition];
		endRect2.origin.x += [self stackPosition];
		endRect3.origin.x += [self stackPosition];
		
	}
	[roundrectView setNeedsDisplay];
	
	/* Set end frame for the three default icons */
	
	
	
		
	
	if ( [[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
	{
		if ([buttonArray count] >= 1)
			
			[[buttonArray objectAtIndex:0] setFrame:endRect1];
		
		if ([buttonArray count] >= 2)
			
			[[buttonArray objectAtIndex:1] setFrame:endRect2];
		
		if ([buttonArray count] >= 3)
			
			[[buttonArray objectAtIndex:2] setFrame:endRect3];	
		
	}
		
	else
	{
		if ([buttonArray count] >= 1)
			
			[[buttonArray objectAtIndex:0] setFrame:endRectOther];
	}
	
	
	/* Set end frame for any other icons */
	
	int c = 0;
	for (MobileStackButton *currentButton in buttonArray)
	{
		if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
		{
			
			
			if (c >= 3)
			{
				[currentButton setFrame:endRectOther];
				currentButton.alpha = 0.0;
			}
		}
		else if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
		{
			[currentButton setFrame:endRectOther];
			currentButton.alpha = 0.0;
		}
		else
		{
			if (c >= 1)
			{
				
				
				[currentButton setFrame:endRectOther];
				currentButton.alpha = 0.0;
			}
		}
		[currentButton hideLabel];
		
		
		c++;
	}
	
	roundrectView.alpha = 0.0f;
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{
		
		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	else
	[toggleStackButton setImage:nil forState:UIControlStateNormal];
	
	/* ---End Animation Block--- */
	
	[UIView commitAnimations];
	
	self.stackWindow.frame = CGRectMake([self stackPosition], rect.size.height-60.0f-1, 60.0f, 90.0f);
	CGRect initialRect = CGRectMake(0.0f, 0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(5.0f, 10.0f, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(0.0f, 5.0f, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(-5.0f, 0.0f, 59.0f, 60.0f);
	
	/* This bit will fix animations */
	int r = 0;
	for (MobileStackButton *currentButton in buttonArray)
	{
		
		if (r >= 3)
		{
			[currentButton setFrame:initialRect];
			
			
		}
		r++;
	}
	
	if ([buttonArray count] >= 1)
		[[buttonArray objectAtIndex:0] setFrame:initialRect3];
	
	if ([buttonArray count] >= 2)
		[[buttonArray objectAtIndex:1] setFrame:initialRect2];
	
	if ([buttonArray count] >= 3)
		[[buttonArray objectAtIndex:2] setFrame:initialRect1];
	
#if SHADOW_ENABLED
	for (MobileStackButton *currentButton in buttonArray)
	{
		[[currentButton _shadow] setCenter:currentButton.center];
	}
#endif		
	[toggleStackButton setFrame:initialRect];
	
	stackOpen = NO;
	
}

#pragma mark -
#pragma mark List View

-(void)_openListView
{
	[self _setupOpen];
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	CGRect rect = [self stackRect];
	
	/* Fill the screen with the grid */
	
	[stackWindow setFrame:CGRectMake(100.0f, 0.0f, 210.0f, rect.size.height+32)];
	[contentView setFrame:CGRectMake(0, 5, [stackWindow frame].size.width, [stackWindow frame].size.height-5-32)];
	
	[roundrectView setFrame:contentView.frame];
	roundrectView.alpha = 1.0;
	[roundrectView setNeedsDisplay];
	
	[toggleStackButton setFrame:CGRectMake([self stackPosition], [stackWindow frame].size.height-[toggleStackButton frame].size.height-32, [toggleStackButton frame].size.width, [toggleStackButton frame].size.height)];
	
	int x = 17.0; // There's method to my madness! SpringBoard seems to use 17px gaps between icons. Odd number, i agree. Seems to fit.
	int y = 35.0; // Start 10px under the status bar
	
	for (MobileStackButton *currentView in buttonArray)
	{
		[currentView showLabelAtRight];
#if SHADOW_ENABLED
		
		currentView._shadow.alpha = 0.0;
#endif
		//currentView.contentMode = UIViewContentModeScaleAspectFill;
		
		//[currentView setFrame:CGRectMake(x, y, 32, 32)];
		//currentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
		//x+=[currentView frame].size.width+17.0;
		
		if (y <= rect.size.height-30)
		{
			y += [currentView frame].size.height + 16.0;
			x = 17.0;
		}
	}	
	
	[UIView commitAnimations];	
	
}

#pragma mark -
- (void) showStack:(id) event 
{	
	[moveTimer invalidate];
	//shouldIgnore = YES;

	[self refreshStackPrefs];
	
#if 1
	
	if ([[stackPrefs valueForKey:@"UseCurvedStack"] boolValue] == YES)
	{
		
		NSLog(@"Curve is enabled");
		useCurvedStack = YES;
	}
	else
	{
		NSLog(@"Curve is disabled");
		useCurvedStack = NO;
	}	
	
	if ([[stackPrefs valueForKey:@"ForceGridView"] boolValue] == YES)
	{
		
		NSLog(@"Grid View is forced");
		forceGridView = YES;
	}
	else
	{
		NSLog(@"Grid View is not forced");
		forceGridView = NO;
	}
#else
	
	useCurvedStack = YES;
	forceGridView = NO;
#endif
	
	
	if (stackOpen) // closing stack
	{
		if ([buttonArray count] > 5 || forceGridView)
		{
			[self _closeGridView];
		}
		else
		{
			[self _closeFanView];
		}
		
	}
	/*
	 * opening stack
	 */
	else
	{		
		if ([buttonArray count] > 5 || forceGridView)	// Grid View!
		{			
			[self _openGridView];		
		}
		else							// Fan View!
		{
			[self _openFanView];		
		}	
		
		/* Enable all buttons */
		
		for (MobileStackButton *currentButton in buttonArray)
		{
			[currentButton setEnabled:YES];
		}	
	}
}

#pragma mark Engine

-(NSMutableDictionary *)initStackPrefs
{		
	NSMutableDictionary *_stackPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:STACK_PREFS_PATH];
	
	//@"/Users/steven/Library/Application Support/iPhone Simulator/User/Library/Preferences/com.steventroughtonsmith.stack.plist"];
	
	if (!_stackPrefs)
	{
		_stackPrefs = [NSMutableDictionary dictionary];
		
		[_stackPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"WarnOnRemove"];
		[_stackPrefs setValue:[NSNumber numberWithInt:245] forKey:@"StackPosition"];
		[_stackPrefs setValue:[NSNumber numberWithBool:NO] forKey:@"ForceGridView"];
		[_stackPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"UseCurvedStack"];
		[_stackPrefs setValue:@"cascade" forKey:@"DisplayAs"];

		
		
		[_stackPrefs writeToFile:STACK_PREFS_PATH atomically:YES];
	}
	
	BOOL __warnRemove, __stackPos, __grid, __curve = NO;
	
	for (NSString *_key in [_stackPrefs allKeys])
	{
		if ([_key isEqualToString:@"WarnOnRemove"])
			__warnRemove = YES;
		
		if ([_key isEqualToString:@"StackPosition"])
			__stackPos = YES;
		
		if ([_key isEqualToString:@"ForceGridView"])
			__grid = YES;
		
		if ([_key isEqualToString:@"UseCurvedStack"])
			__curve = YES;
	}	
	
	if (!__warnRemove)
		[_stackPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"WarnOnRemove"];
	
	if (!__stackPos)
		[_stackPrefs setValue:@"br" forKey:@"StackPosition"];
	
	if (!__grid)
		[_stackPrefs setValue:[NSNumber numberWithBool:NO] forKey:@"ForceGridView"];
	
	if (!__curve)
		[_stackPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"UseCurvedStack"];
	
	[_stackPrefs writeToFile:STACK_PREFS_PATH atomically:YES];
	
	stackPrefs = [[NSMutableDictionary dictionaryWithDictionary:_stackPrefs] retain];
	
}

-(void)saveStackPrefs
{
	[stackPrefs writeToFile:STACK_PREFS_PATH atomically:YES];
}

-(void)refreshStackPrefs
{
	[stackPrefs autorelease];
	NSMutableDictionary *_stackPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:STACK_PREFS_PATH];
	
	stackPrefs = [[NSMutableDictionary dictionaryWithDictionary:_stackPrefs] retain];
	
}


//FIXME: Hacky hack!

- (void) didInjectIntoProgram {
    [self performSelector: @selector(inject) withObject: nil afterDelay: 0.1];
}

int notification_token;


-(void)inject
{	
	sharedInstance = self;
	
	MobileStackEngineInitialize();
	
	[self initStackPrefs];
	
	NSLog(@"MobileStack: didInjectIntoProgram");
	CGRect rect = [UIScreen mainScreen].bounds;
	
    rect.origin.x = rect.origin.y = 0.0f;
	CGRect initialRect = CGRectMake(0.0f, 0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(5.0f, 10.0f, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(0.0f, 5.0f, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(-5.0f, 0.0f, 59.0f, 60.0f);
	
	self.stackWindow = [[[StackWindow alloc] initWithFrame:CGRectMake([self stackPosition], rect.size.height-80.0f, 60.0f, 90.0f)] retain];
	self.stackWindow.opaque = NO;
	//	_settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	//[_settingsButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_preferences.png"] forState:UIControlStateNormal];
	
	//[_settingsButton addTarget:[MobileStackPreferencesController sharedInstance] action:@selector(showPreferencesWindow:) forControlEvents:UIControlEventTouchDown];
	
	
	NSLog(@"MobileStack: window = set");
	
	self.contentView = [[[UIView alloc] initWithFrame: CGRectMake(0,0, [stackWindow frame].size.width, [stackWindow frame].size.height-20.0f)] retain];
	roundrectView = [[[SGridView alloc] initWithFrame: [contentView bounds]] retain];
	roundrectView.alpha = 0.0;
	
	/* Customization Code here */
	/* Load the Stack entries from the file, or if there are none init with the default three and write it to disk */
	
	buttonStoreArray = [[NSMutableArray arrayWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath]] retain];
	NSLog(@"MobileStack: Button array = set");
	
	if (!buttonStoreArray)
	{
		buttonStoreArray = [[NSMutableArray array] retain];
		
		NSDictionary *_one = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"com.apple.MobileAddressBook", nil] forKeys:[NSArray arrayWithObjects:@"ID", nil]];
		NSDictionary *_two = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"com.apple.mobilesafari", nil] forKeys:[NSArray arrayWithObjects:@"ID", nil]];
		NSDictionary *_three = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"com.apple.Preferences", nil] forKeys:[NSArray arrayWithObjects:@"ID", nil]];
		
		[buttonStoreArray addObject:_one];
		[buttonStoreArray addObject:_two];
		[buttonStoreArray addObject:_three];
		
		BOOL success = [buttonStoreArray writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath] atomically:NO];
		
		if (!success)
		{
			NSLog(@"Stack: Fatal Error! Could not write default Stack entry config. Permissions failure?");
		}
		
	}
	
	buttonArray = [[NSMutableArray array] retain];
	
	/* End */
	
	/* Enable the following code if you want to check the bounds of the main window and its content view. Yes, they will draw with a charming duotone of red and green. Makes it feel like Christmas */
	//#define DRAWING_DEBUG
	
#if DRAWING_DEBUG
	[stackWindow setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
	[contentView setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]];
	//[boom setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0]];
	
	NSLog(@"MobileStack: DRAWING_DEBUG");
	
#endif
	
	NSLog(@"MobileStack: About to setup buttons");
	
	
	Class SBApplicationController = objc_getClass("SBApplicationController");
	
	NSLog(@"MobileStack: class got");
	SBApplicationController *appController = [SBApplicationController sharedInstance];
	//	
	//	id t = [SBApplicationController sharedInstance];
	//	
	//	if (!t)
	//		break;
	
	
	NSLog(@"MobileStack: About to setup buttons (really this time)");
	
	
	/* Set up the buttons */
	
	if ([buttonStoreArray count] > 0)
	{
		
		int i = 0;
		for (NSDictionary *currentItem in buttonStoreArray )
		{
			NSLog(@"MobileStack: Button %i setup", i);
			
			if (i >= 0)
			{			
				SBApplication *app = [appController applicationWithDisplayIdentifier:[currentItem objectForKey:@"ID"]];
				
				if (!app)
				{
					NSLog(@"MobileStack: App doesnt exist");
				}
				else
				{
					CGRect _itemRect = initialRect;
					BOOL _isHidden = YES;
					
					if (![[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
					{
						if ( i == 0)
						{
							_itemRect = initialRect3;
							_isHidden = NO;
						}
					}
					
					if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
					{
						if ( i == 1)
						{
							_itemRect = initialRect2;
							_isHidden = NO;
						}
						if ( i == 2)
						{
							_itemRect = initialRect1;
							_isHidden = NO;
						}
					}
					
					//NSLog(@"MobileStack: ButStart");
					
					MobileStackButton *currentButton = [[MobileStackButton alloc] initWithFrame:initialRect];
					//NSLog(@"MobileStack: ButStart +1 ");
					
					[currentButton setApplication:app];
					[currentButton setFrame:_itemRect];
					//[currentButton setImage:[UIImage imageWithContentsOfFile:[app pathForIcon]] forState:UIControlStateNormal];
					[currentButton addTarget:self action:@selector(decideRemoveItemFromStack:) forControlEvents:UIControlEventTouchDragOutside];
					
					//NSLog(@"MobileStack: ButStart +2 ");
					
					[currentButton addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside];
					
					//NSLog(@"MobileStack: ButStart +3");
					
					//currentButton.representedObject = currentItem;
					
					//NSLog(@"MobileStack: ButStart +4");
					
					currentButton.hidden = _isHidden;
					
					//NSLog(@"MobileStack: ButStart +5");
					
					currentButton.adjustsImageWhenDisabled = NO;
					
					//NSLog(@"MobileStack: ButStart +6");
					
					[buttonArray addObject:currentButton];
					i++;
				}
				//	NSLog(@"MobileStack: ButComplete");
			}
		}
	}
	NSLog(@"MobileStack: Create the Stack toggle button");
	
	/* Create the Stack toggle button */
	
	toggleStackButton = [[MobileStackButton alloc] initWithFrame:initialRect];
	[toggleStackButton setEnabled:YES];
	[toggleStackButton addTarget:self action:@selector(showStack:) forControlEvents:UIControlEventTouchUpInside];
	[toggleStackButton addTarget:self action:@selector(startMoveTimer:) forControlEvents:UIControlEventTouchDown];
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{

		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	
	/* Disable all the buttons except the toggle button to prevent spurious app launches */
	
	for (MobileStackButton *currentButton in buttonArray)
	{
		[currentButton setEnabled:NO];
	}
	
	[contentView addSubview:roundrectView];
	
	for (MobileStackButton *currentButton in buttonArray)
	{
		[contentView addSubview:currentButton];
	}
	
	[contentView addSubview:toggleStackButton];	
	[stackWindow addSubview:contentView];
	
	NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(_sbHeartBeatTimer) userInfo:nil repeats:YES];
	
	//[stackWindow addSubview:_settingsButton];
	//	_settingsButton.hidden = YES;
	//	
	[stackWindow makeKeyAndVisible];
	[stackWindow release];
	
	//[self performSelectorInBackground:@selector(notification_thread) withObject:nil];
	
	NSLog(@"Stack Injection Complete");
}

#if 0
-(void)notification_thread
{
	int was_posted;
	while (1) {
		sleep(1);
		
		if (notify_check(notification_token, &was_posted)) {
			printf("Call to notify_check failed.\n"); exit(-1);
		}
		if (was_posted) {
			/* The notification org.apache.httpd.configFileChanged
			 was posted. */
			
			[[MobileStack sharedInstance] _settingsChanged];
			printf("Notification %d was posted.\n", notification_token);
		}
	}
	
}
#endif

BOOL _hackedBB = NO;

-(void)_sbHeartBeatTimer
{
	Class SBUIController = objc_getClass("SBUIController");
	Class SBIconList = objc_getClass("SBIconList");
	
	SBUIController *uiController = [SBUIController sharedInstance];
	
	SBLaunchState _launchState;
	object_getInstanceVariable(uiController, "_launchState", (void **)&_launchState);
	
	//NSLog(@"launchstate = %i", [[NSClassFromString(@"SBIconController") sharedInstance] currentIconListIndex]);
	
	//Class SBUIController = objc_getClass("SBUIController");
	//	id uiController = [SBUIController sharedInstance];
	
	UIView *_buttonBarContainerView;
	object_getInstanceVariable(uiController, "_buttonBarContainerView", (void **)&_buttonBarContainerView);
	
	//if (0)//!_hackedBB)
//	{
//		UIView *buttonBar = [[_buttonBarContainerView subviews] objectAtIndex:0];
//		CGRect f = [buttonBar frame];
//		NSLog(@"Dbug: %@", NSStringFromClass([buttonBar class]));
//		
//		UIScrollView *_buttonBarScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 230, 90)];
//		_buttonBarScroller.contentSize = buttonBar.frame.size;
//		[_buttonBarScroller addSubview:buttonBar];
//		[_buttonBarScroller setClipsToBounds:YES];
//		
//		[_buttonBarContainerView addSubview:_buttonBarScroller];
//		[_buttonBarScroller release];
//		_hackedBB = YES;
//	}
	
	//	if (0)
	//	//if (![NSStringFromClass([[_buttonBarContainerView objectAtIndex:0] class]) isEqualToString:@"UIScrollView"])
	//	{
	//
	//		UIScrollView *_buttonBarScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 230, 90)];
	//		_buttonBarScroller.contentSize = CGSizeMake(320, 90);
	////		SBIconList *iconList = [[SBIconList alloc] initWithFrame:f];
	//
	//		//for (SBIcon *icon in [cont icons])
	////		{
	////			
	////			[icon removeFromSuperview];
	////			[_buttonBarScroller addSubview:icon];
	////
	////			//[iconList addSubview:icon];
	////		}
	//		
	////		[_buttonBarScroller addSubview:iconList];
	//
	//		[cont removeFromSuperview];
	//		[_buttonBarScroller addSubview:cont];
	//
	//		[_buttonBarContainerView addSubview:_buttonBarScroller];
	//		[_buttonBarScroller flashScrollIndicators];
	//		[_buttonBarScroller setScrollEnabled:YES];
	//		_buttonBarScroller.canCancelContentTouches = NO;
	//		_buttonBarScroller.bounces = YES;
	//	}
	
	//	
	//	[cont setFrame:CGRectMake(f.origin.x, f.origin.y, 230, f.size.height)];
	//	
	
	[UIView beginAnimations:@"stack_fade_out" context:nil];
	
	
	NSInteger listIndex = 0;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) /* iPhone 3.0 API Change */
	listIndex = (int)[[NSClassFromString(@"SBIconController") sharedInstance] currentIconListIndex];
	
	if (listIndex == -1 || _launchState != SBLaunchStateNormal && _launchState != SBLaunchStateAnimatingClosed)
		[stackWindow setAlpha:0.0];
	else
	{
		
		if (stackWindow.alpha != 1.0)
		{
			if (stackOpen)
				[stackWindow setFrame:CGRectMake([self stackPosition]-DELTA, stackWindow.frame.origin.y, stackWindow.frame.size.width, stackWindow.frame.size.height)];
			
			[stackWindow setAlpha:1.0];
			[self refreshStackPrefs];
		}
	}
	
	[UIView commitAnimations];	
}



-(void)displayPoofAtOrigin:(CGPoint)origin
{
	if (!poofImageView)
	{
		poofImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(origin.x, origin.y, 57, 57)] retain]; 
		
		/* Images cribbed from Dock.app on Desktop! Sorry Apple! */
		
		UIImage *poof1 = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/poof_1.png"];
		UIImage *poof2 = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/poof_2.png"];
		UIImage *poof3 = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/poof_3.png"];
		UIImage *poof4 = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/poof_4.png"];
		UIImage *poof5 = [UIImage imageWithContentsOfFile:@"/Library/MobileStack/poof_5.png"];
		
		[poofImageView setAnimationImages:[NSArray arrayWithObjects:poof1, poof2, poof3, poof4, poof5, nil]];
		[poofImageView setAnimationDuration:0.3];
	}
	
	[poofImageView setFrame:CGRectMake(origin.x, origin.y, 57, 57)];
	[stackWindow addSubview:poofImageView];
	//[poofImageView release];
	
	[poofImageView startAnimating];
	
	[poofImageView performSelector:@selector(stopAnimating) withObject:self afterDelay:0.3];
	[poofImageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
}

#pragma mark Housekeeping

-(void)addItemToStack:(NSString *)identifier
{
	if ([buttonStoreArray count] >= 16)
		return;
	
	NSLog(@"MobileStack: addItemToStack: %@", identifier);
	
	for (NSDictionary* cur in buttonStoreArray)
	{
		if ([[cur objectForKey:@"ID"] isEqualToString:identifier]) // Reject the new item if it's already here
			return;
	}
	
	CGRect initialRect = CGRectMake(0.0f, 0.0f, 59.0f, 60.0f);
	
	Class SBApplicationController = objc_getClass("SBApplicationController");
	SBApplicationController *appController = [SBApplicationController sharedInstance];
	
	SBApplication *currentApp = [appController applicationWithDisplayIdentifier:identifier];
	
	NSDictionary *_newItem = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:identifier, nil] forKeys:[NSArray arrayWithObjects:@"ID", nil]];
	
	[buttonStoreArray addObject:_newItem];
	
	MobileStackButton *currentButton = [[MobileStackButton alloc] initWithFrame:initialRect];
	
	[currentButton setApplication:currentApp];
	
	//	if ([currentApp pathForIcon])	
	//	{
	//			
	//		[currentButton setApplication:currentApp];//setImagePath:[currentApp pathForIcon]];//setImage:[UIImage imageWithContentsOfFile:[currentApp pathForIcon]] forState:UIControlStateNormal];
	//	}
	//	else
	//		[currentButton setImagePath:@"/Library/MobileStack/stack_empty_icon.png"];
	//[currentButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_empty_icon.png"] forState:UIControlStateNormal];
	
	[currentButton addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside];
	[currentButton addTarget:self action:@selector(decideRemoveItemFromStack:) forControlEvents:UIControlEventTouchDragOutside];
	//currentButton.representedObject = _newItem;
	currentButton.hidden = YES;
	currentButton.adjustsImageWhenDisabled = NO;
	
	[buttonArray addObject:currentButton];
	[contentView addSubview:currentButton];
	[currentButton release];
	
	[buttonStoreArray writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath]  atomically:YES];
}

id _remove_context_item;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex

{
	NSLog(@"deesmiss");
	
	if (buttonIndex == 0)
	{
		//[self removeItemFromStack:_remove_context_item];
	}
	else
	{
		[self removeItemFromStack:_remove_context_item];
	}
	
	_remove_context_item = nil;
}

-(void)decideRemoveItemFromStack:(id)sender
{	
	[self refreshStackPrefs];
	
	if ([[stackPrefs valueForKey:@"WarnOnRemove"] boolValue] == YES)
	{
		_remove_context_item = sender;
		
		UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Remove" message:[NSString stringWithFormat:@"Are you sure you want to remove %@ from Stack?", [sender displayName]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
		[v show];
		[v release];
	}
	else
	{
		[self removeItemFromStack:sender];
	}
}

-(void)removeItemFromStack:(id)sender
{	
	NSDictionary *_cur;	
	MobileStackButton *button;
	
	for (NSDictionary* cur in buttonStoreArray)
	{
		
		if ([[cur objectForKey:@"ID"] isEqualToString:[sender representedDisplayIdentifier]])
			_cur = cur;
		
		for (MobileStackButton *currentButton in buttonArray)
		{
			if ([[currentButton representedDisplayIdentifier] isEqualToString:[sender representedDisplayIdentifier]])
				button = [currentButton retain];
		}
		
		[self displayPoofAtOrigin:[button frame].origin];	
	}
	
	[buttonArray removeObject:button];
	[button removeFromSuperview];
	
	[buttonStoreArray removeObject:_cur];
	[self showStack:self];
	
	[buttonStoreArray writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath]  atomically:YES];
	
}

-(void)openApp:(id)sender
{
	
	//CGPoint p = GSEventGetLocationInWindow(event);
	/*
	 if (!CGRectContainsPoint([UIScreen mainScreen].bounds, p))
	 {
	 return;
	 }
	 */
	//	[0x12345 crash];
	//	
	//	return;
	
	[self showStack:self];
	
	Class SBUIController = objc_getClass("SBUIController");
	SBUIController *uiController = [SBUIController sharedInstance];
	
	Class SBApplicationController = objc_getClass("SBApplicationController");
	SBApplicationController *appController = [SBApplicationController sharedInstance];
	
	

	SBApplication *app = [appController applicationWithDisplayIdentifier:[sender representedDisplayIdentifier]];

if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.0) /* iPhone 3.0 API Change */
	[uiController animateLaunchApplication:app];
else
	[uiController activateApplicationAnimated:app];

}

@end

