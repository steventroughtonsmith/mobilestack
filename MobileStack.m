#import "MobileStack.h"
BOOL stackOpen = NO;

BOOL useCurvedStack = YES;
BOOL forceGridView = NO;

float timescale = 0.3;


@implementation UIView (Color)

+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
{
    float rgba[4] = {red, green, blue, alpha};
    CGColorSpaceRef rgbColorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
    CGColorRef color = (CGColorRef)[(id)CGColorCreate(rgbColorSpace, rgba) autorelease];
    return color;
}

@end

@implementation StackContentView

-(BOOL)isOpaque
{
return NO;
}

/* http://phonedev.tumblr.com/post/10385140 */

- (void)drawRect:(CGRect)rect;
{
	
	rect = CGRectInset(rect, 7, 20);
	rect.size.height -= 60;
	
	UIBezierPath *path = [UIBezierPath roundedRectBezierPath:rect withRoundedCorners:kUIBezierPathAllCorners withCornerRadius:5.0];
	
	[path setLineWidth:4.0];
	CGContextSetFillColorWithColor(UICurrentContext(), [UIView colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.7]);

	[path fill];
	
	UIBezierPath *arrow = [UIBezierPath bezierPath];
	
	[arrow moveToPoint:CGPointMake(rect.size.width-18, rect.size.height+20)];
	[arrow lineToPoint:CGPointMake(rect.size.width-33, rect.size.height+20+15)];
	[arrow lineToPoint:CGPointMake(rect.size.width-48, rect.size.height+20)];
	[arrow closePath];
	
	[arrow fill];	

}


@end


@implementation StackButton

-(void)setRepresentedObject:(id)obj
{
	[_representedObject release];
	_representedObject = [obj retain];
}

-(id)representedObject
{
	return [_representedObject retain];
}

@end


@implementation MobileStack

- (void) animator:(UIAnimator *) animator stopAnimation:(UIAnimation *) animation {
	CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
	
	if (!stackOpen)
	{	

		CGRect endRect1 = CGRectMake(5.0f, 10.0f, 59.0f, 60.0f);
		CGRect endRect2 = CGRectMake(0.0f, 5.0f, 59.0f, 60.0f);
		CGRect endRect3 = CGRectMake(-5.0f, 0.0f, 59.0f, 60.0f);
		CGRect endRectOther = CGRectMake(0.0f, 5.0f, 59.0f, 60.0f);

		[firstImageView setFrame:endRect3];
		[secondImageView setFrame:endRect2];
		[thirdImageView setFrame:endRect1];
		
		int c = 0;
		for (UIView *currentView in buttonArray)
		{
			if (c >= 3)
				[currentView setFrame:endRectOther];
			c++;
		}

		[toggleStackButton setBackgroundImage:nil];	
		
		[window setFrame:CGRectMake(rect.size.width - 75.0f, rect.size.height-70.0f, 60.0f, 90.0f)];
		[contentView setFrame:CGRectMake(0,0, [window frame].size.width, [window frame].size.height-20)];
		[roundrectView setFrame:[contentView bounds]];
		[toggleStackButton setFrame:CGRectMake(0.0f, 0, 59.0f, 60.0f)];

	}



	[roundrectView setNeedsDisplay];

	
	
	[window orderFront: self];
	[window makeKey: self];

}

-(void)blackout:(BOOL)b
{
	
	if (b)
	{
	
	[blackoutWindow orderFront: self];
	[window orderFront: self];
	[window makeKey: self];
	
	NSMutableArray *animations = nil;
	animations = [[NSMutableArray alloc] initWithCapacity:1];
	
	fadeAnimation = [[UIAlphaAnimation alloc] initWithTarget:blackoutWindow];
	[fadeAnimation setEndAlpha:1.0];
	[fadeAnimation setStartAlpha:0.0];
	[fadeAnimation setDelegate:self];
	
	[animations addObject:fadeAnimation];
	[[UIAnimator sharedAnimator] addAnimations:animations withDuration:timescale start:YES];
	
	}
	else
	{
	[blackoutWindow orderFront: self];
	[window orderFront: self];
	[window makeKey: self];
	
	NSMutableArray *animations = nil;
	animations = [[NSMutableArray alloc] initWithCapacity:1];
	
	fadeAnimation = [[UIAlphaAnimation alloc] initWithTarget:blackoutWindow];
	[fadeAnimation setEndAlpha:0.0];
	[fadeAnimation setStartAlpha:1.0];
	[fadeAnimation setDelegate:self];
	
	[animations addObject:fadeAnimation];
	[[UIAnimator sharedAnimator] addAnimations:animations withDuration:timescale start:YES];

	}
}


- (void) showStack:(id) event 
{
	/* Query Stack preferences */
	
	NSDictionary *stackPrefs = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack" stringByExpandingTildeInPath]];
	if (!stackPrefs)
	stackPrefs = [NSMutableDictionary dictionary];

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
	
	/* Resize Stack window height to match screen height to make room for animations and button targets */

	CGRect rect = [UIHardware fullScreenApplicationContentRect];

	if (stackOpen)
	{
	
		/* Return Stack main window to default level */
	
		[window setLevel:0];
		
		/* Disable all controls during animation */
		
		for (UIView *currentView in buttonArray)
		{
			[currentView setEnabled:NO];
		}
		
		/* Remove the dimming effect */

		[self blackout:NO];
		
		/* Setup the end frames */

		CGRect endRectOther = CGRectMake(0.0f, rect.size.height-80, 59.0f, 60.0f);
		CGRect endRect1 = CGRectMake(5.0f, rect.size.height-75, 59.0f, 60.0f);
		CGRect endRect2 = CGRectMake(0.0f,  rect.size.height-80, 59.0f, 60.0f);
		CGRect endRect3 = CGRectMake(-5.0f, rect.size.height-85, 59.0f, 60.0f);

		/* ---Start Animation Block--- */
		
		[UIView beginAnimations:nil]; 
		[UIView setAnimationDuration:timescale]; 
		
		if ([buttonArray count] <= 5 && !forceGridView)
		{
		[window setFrame:CGRectMake(rect.size.width - 75.0f, 00.0f, 60.0f, rect.size.height)];
		[contentView setFrame:CGRectMake(0, 0, [window frame].size.width, [window frame].size.height)];
		[roundrectView setFrame:[contentView bounds]];
		[toggleStackButton setFrame:CGRectMake(0.0f, [window frame].size.height-[toggleStackButton frame].size.height, 59.0f, 60.0f)];
		
		}
		else
		{
		
		endRectOther.origin.x += rect.size.width - 75.0f;
		endRect1.origin.x += rect.size.width - 75.0f;
		endRect2.origin.x += rect.size.width - 75.0f;
		endRect3.origin.x += rect.size.width - 75.0f;
		
		}
			[roundrectView setNeedsDisplay];


		
		/* Set end frame for the three default icons */
		
		[firstImageView setFrame:endRect1];
		[secondImageView setFrame:endRect2];
		[thirdImageView setFrame:endRect3];		
		
		/* Set end frame for any other icons */
		
		int c = 0;
		for (UIView *currentView in buttonArray)
		{
			if (c >= 3)
				[currentView setFrame:endRectOther];
			c++;
		}
		
		if ([buttonArray count] > 5 || forceGridView)	// Grid View! Ergo NO ROTATION
		{
		}
		else							// Rotate icons back!
		{
			/* Set Item Rotation */
			if (useCurvedStack)
			{
				int i = 2;
				for (UIView *currentView in buttonArray)
				{
					
						[currentView setRotationBy:i];
						i=i+2;
				}
			}	
		}
		
		[roundrectView setAlpha:0.0];
		
		/* ---End Animation Block--- */
		
		[UIView endAnimations];
		
		stackOpen = NO;

	}
	else
	{
		/* Make sure Stack window is topmost while Stack is opening */

		[window setLevel:2];
		
		/* Dim screen and order Stack window front*/

		[self blackout:YES];
		[window orderFront: self];
		[window makeKey: self];
		
		/* Setup reference rect */

		CGRect initialRect = CGRectMake(0.0f, rect.size.height-70, 59.0f, 60.0f);
		
		/* Place Stack minimization button */
		
		[toggleStackButton setFrame:CGRectMake(0.0f, rect.size.height-60, 59.0f, 60.0f)];
		[toggleStackButton setBackgroundImage:[UIImage applicationImageNamed:@"stackicon.png"] ];
		
		/* Position all buttons on the starting rect */
		
		for (UIView *currentView in buttonArray)
		{
			[currentView setFrame:initialRect];
		}
			
		stackOpen = YES;
		
		[window setFrame:CGRectMake(rect.size.width - 75.0f, 00.0f, 60.0f, rect.size.height)];
		[contentView setFrame:CGRectMake(0, 0, [window frame].size.width, [window frame].size.height)];
		[roundrectView setFrame:[contentView bounds]];

		
		/* ---Start Animation Block--- */
		
		[UIView beginAnimations:nil]; 
		[UIView setAnimationDuration:timescale]; 
		
		/* Setup initial end rect */
		
		CGRect currentEndRect = initialRect;
		
		if ([buttonArray count] > 5 || forceGridView)	// Grid View!
		{
			
			/* Fill the screen with the grid */
			
			[window setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
			[contentView setFrame:CGRectMake(0, 0, [window frame].size.width, [window frame].size.height)];
			[roundrectView setFrame:[contentView bounds]];
			[roundrectView setAlpha:1.0];
				[roundrectView setNeedsDisplay];

			[toggleStackButton setFrame:CGRectMake(rect.size.width - 75.0f, [window frame].size.height-[toggleStackButton frame].size.height, [toggleStackButton frame].size.width, [toggleStackButton frame].size.height)];

			int x = 17.0; // There's method to my madness! SpringBoard seems to use 17px gaps between icons. Odd number, i agree. Seems to fit.
			int y = 30.0; // Start 10px under the status bar
			
			for (UIView *currentView in buttonArray)
			{
				[currentView setFrame:CGRectMake(x, y, [currentView frame].size.width, [currentView frame].size.height)];
				
				x+=[currentView frame].size.width+17.0;
				
				if (x >= rect.size.width-30)
				{
				y += [currentView frame].size.height + 17.0;
				x = 17.0;
				}
			}
		
		
		
		}
		else							// Fan View!
		{
			/* Set position and rotation of all buttons procedurally */
			
			int i = -2;
			int x = 0;
			int m = 0;
			for (UIView *currentView in buttonArray)
			{
				currentEndRect.origin.y-=70;
				if (useCurvedStack)
				{
					currentEndRect.origin.x=x;
					if (x == 0) x = -3; else x = x-3*(m+1);		// LOL at my code... I have no idea how it works either.
					m++;
				}
				[currentView setFrame:currentEndRect];
				
				if (useCurvedStack)
				{	
					[currentView setRotationBy:i];
					i=i-2;
				}
				
			}
		}	
		
		/* Enable all buttons */

		for (UIView *currentView in buttonArray)
		{
			[currentView setEnabled:YES];
		}
		
		
		[UIView endAnimations];
		
		/* ---End Animation Block--- */

	}

}

- (void) applicationDidFinishLaunching: (id) unused
{

	CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
	CGRect initialRect = CGRectMake(0.0f, 0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(5.0f, 10.0f, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(0.0f, 5.0f, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(-5.0f, 0.0f, 59.0f, 60.0f);

	CGRect left = CGRectMake(0.0f, 0.0f, 6.0f, 60.0f);
	CGRect middle = CGRectMake(6.0f, 0.0f, 48.0f, 60.0f);
	CGRect right = CGRectMake(54.0f, 0.0f, 6.0f, 60.0f);
	CDAnonymousStruct4 slices = { left, middle, right };
	
	CGRect iconleft = CGRectMake(0.0f, 0.0f, 5.0f, 60.0f);
	CGRect iconmiddle = CGRectMake(5.0f, 0.0f, 45.0f, 60.0f);
	CGRect iconright = CGRectMake(50.0f, 0.0f, 10.0f, 60.0f);
	CDAnonymousStruct4 iconslices = { iconleft, iconmiddle, iconright };

	window = [[UIWindow alloc] initWithContentRect:CGRectMake(rect.size.width - 75.0f, rect.size.height-70.0f, 60.0f, 90.0f)];
	contentView = [[UIView alloc] initWithFrame: CGRectMake(0,0, [window frame].size.width, [window frame].size.height-20.0f)];
	roundrectView = [[StackContentView alloc] initWithFrame: [contentView bounds]];
	[roundrectView setAlpha:0.0];

	[contentView addSubview:roundrectView];
	
	/* Customization Code here */
	/* Load the Stack entries from the file, or if there are none init with the default three and write it to disk */
	
	buttonStoreArray = [NSMutableArray arrayWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries" stringByExpandingTildeInPath]];
	
	if (!buttonStoreArray)
	{
		buttonStoreArray = [[NSMutableArray array] retain];

		NSDictionary *_one = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"com.apple.mobilemail", @"/Applications/MobileMail.app/icon.png",nil] forKeys:[NSArray arrayWithObjects:@"ID", @"IconPath", nil]];
		NSDictionary *_two = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"com.apple.mobilenotes", @"/Applications/MobileNotes.app/icon.png",nil] forKeys:[NSArray arrayWithObjects:@"ID", @"IconPath", nil]];
		NSDictionary *_three = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"com.apple.Maps", @"/Applications/Maps.app/icon.png",nil] forKeys:[NSArray arrayWithObjects:@"ID", @"IconPath", nil]];
				
		[buttonStoreArray addObject:_one];
		[buttonStoreArray addObject:_two];
		[buttonStoreArray addObject:_three];

		BOOL success = [buttonStoreArray writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries" stringByExpandingTildeInPath] atomically:NO];
		
		if (!success)
		{
			NSLog(@"Stack: Fatal Error! Could not write default Stack entry config.");
		}
	
	}
	
	buttonArray = [[NSMutableArray array] retain];
	
	/* End */
	
	/* Enable the following code if you want to check the bounds of the main window and its content view. Yes, they will draw with a charming duotone of red and green. Makes it feel like Christmas */

#ifdef DRAWING_DEBUG
	[window setBackgroundColor:[UIView colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
	[contentView setBackgroundColor:[UIView colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]];
#endif

	/* Three items is a minimum (and default) for Stack. Set them up here. */
	
#warning FIXME: No error checking for array to make SURE it has at least three items. What will happen then? Only Chuck Norris knows..	

	firstImageView = [[StackButton alloc] initWithTitle: @""];
	[firstImageView setAutosizesToFit:NO];
	[firstImageView setFrame:initialRect3];
	[firstImageView setBackgroundSlices:iconslices];
	[firstImageView setBackgroundImage:[UIImage imageAtPath:[[buttonStoreArray objectAtIndex:0] objectForKey:@"IconPath"]]];
	[firstImageView addTarget:self action:@selector(openApp:) forEvents:1];
	[firstImageView setRepresentedObject:[buttonStoreArray objectAtIndex:0]];
	[buttonArray addObject:firstImageView];
	
	secondImageView = [[StackButton alloc] initWithTitle: @""];
	[secondImageView setAutosizesToFit:NO];
	[secondImageView setFrame:initialRect2];
	[secondImageView setBackgroundSlices:iconslices];
	[secondImageView setBackgroundImage:[UIImage imageAtPath:[[buttonStoreArray objectAtIndex:1] objectForKey:@"IconPath"]]];
	[secondImageView addTarget:self action:@selector(openApp:) forEvents:1];
	[secondImageView setRepresentedObject:[buttonStoreArray objectAtIndex:1]];
	[buttonArray addObject:secondImageView];	
		
	thirdImageView = [[StackButton alloc] initWithTitle:@""];
	[thirdImageView setAutosizesToFit:NO];
	[thirdImageView setFrame:initialRect1];
	[thirdImageView setBackgroundSlices:iconslices];	
	[thirdImageView setBackgroundImage:[UIImage imageAtPath:[[buttonStoreArray objectAtIndex:2] objectForKey:@"IconPath"]]];
	[thirdImageView addTarget:self action:@selector(openApp:) forEvents:1];
	[thirdImageView setRepresentedObject:[buttonStoreArray objectAtIndex:2]];
	[buttonArray addObject:thirdImageView];	
	
	/* Set up anything past the third item */

	if ([buttonStoreArray count] > 3)
	{
	
		int i = 0;
		for (NSDictionary *currentItem in buttonStoreArray)
		{
		
			if (i >= 3)
			{
				StackButton *currentButton = [[StackButton alloc] initWithTitle:@""];
				[currentButton setAutosizesToFit:NO];
				[currentButton setFrame:initialRect];
				[currentButton setBackgroundSlices:iconslices];	
				[currentButton setBackgroundImage:[UIImage imageAtPath:[currentItem objectForKey:@"IconPath"]]];
				[currentButton addTarget:self action:@selector(openApp:) forEvents:1];
				[currentButton setRepresentedObject:currentItem];
				[buttonArray addObject:currentButton];
			}
			i++;
		}
	}
	
	/* Create the Stack toggle button */

	toggleStackButton = [[UIThreePartButton alloc] initWithTitle:@""];
	[toggleStackButton setEnabled:YES];
	[toggleStackButton setAutosizesToFit:NO];
	[toggleStackButton setFrame:initialRect];
	[toggleStackButton setBackgroundSlices:slices];
	[toggleStackButton setBackgroundImage:nil];
	[toggleStackButton addTarget:self action:@selector(showStack:) forEvents:1];
	
	/* Disable all the buttons except the toggle button to prevent spurious app launches */

	for (UIView *currentView in buttonArray)
	{
		[currentView setEnabled:NO];
	}
	
	/* Add all buttons past #3 at the bottom of the view tree - i.e. first */
	
	int i = 0;

	for (UIView *currentView in buttonArray)
	{
		if (i >= 3)
			[contentView addSubview:currentView];
		i++;
	}
	
	/* Layer the three icons and the toggle button on top */

	[contentView addSubview:firstImageView];
	[contentView addSubview:secondImageView];
	[contentView addSubview:thirdImageView];
	[contentView addSubview:toggleStackButton];
	
	[window setContentView:contentView];
	[window orderFront: self];
	[window makeKey: self];
	
	/* Init the dim window (dropped on its head at birth, no doubt) */
	
	blackoutWindow = [[UIWindow alloc] initWithContentRect:CGRectMake(0, 0,  rect.size.width,  rect.size.height+20)];
	[blackoutWindow setBackgroundColor:[UIView colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];

}


-(void)openApp:(id)sender
{

[self showStack:self];
[self launchApplicationWithIdentifier:[[sender representedObject] objectForKey:@"ID"] suspended:NO];

}

@end
