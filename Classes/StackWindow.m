//
//  StackWindow.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 16/02/2009.
//  Copyright 2009 Steven Troughton-Smith. All rights reserved.
//

#import "StackWindow.h"
#import "MobileStack.h"

@implementation StackWindow

#if 0
- (void)mouseUp:(GSEvent *)event
{
	//self.exclusiveTouch = YES;
	
	//NSLog(@"touches!!");
	
	if (1)//GSEventGetLocationInWindow(event).y < 480-90)
	{
		if ([[MobileStack sharedInstance] stackOpen]) return; 
		
		[[MobileStack sharedInstance] redisplay]; 

	}
	//if (GSEventGetClickCount(event) == 2)
	
}
#endif


/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)e
{
	UITouch *t = [touches anyObject];

	[self performSelector:@selector(startMoving:) withObject:t afterDelay:0.1];
}

-(void)startMoving:(UITouch *)t
{
	if (t.phase == UITouchPhaseStationary)
	[[MobileStack sharedInstance] startMoving:self]; 
}
*/

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)e
{
	if ([[MobileStack sharedInstance] isMoving])
	{
		

	NSLog(@"touches moved 3.0!!");
	UITouch *t = [touches anyObject];

	CGRect r = [[[self subviews] objectAtIndex:0] frame];
	
	//r.origin.x = GSEventGetLocationInWindow(event).x;
	
	CGFloat x = [t locationInView:self].x;
	r.origin.x = x;
	
	if (x > 0.0 && x < 320.0-60.0)
	{
		if ([[MobileStack sharedInstance] stackOpen]) return; 
		[[[self subviews] objectAtIndex:0] setFrame:r];
		
		
	}
			}
}

- (void)mouseDragged:(GSEvent *)event
{
	if ([[MobileStack sharedInstance] isMoving])
	{
		
	NSLog(@"touches moved 2.0!!");
	
	CGRect r = [[[self subviews] objectAtIndex:0] frame];
	
	//r.origin.x = GSEventGetLocationInWindow(event).x;
	
	CGFloat x = GSEventGetLocationInWindow(event).x;
	r.origin.x = x;
	
	if (x > 0.0 && x < 320.0-60.0)
	{
		if ([[MobileStack sharedInstance] stackOpen]) return; 

		//[[MobileStack sharedInstance] redisplay]; 
		[[[self subviews] objectAtIndex:0] setFrame:r];

	
	}
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
