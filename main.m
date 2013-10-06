//
//  main.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 07/03/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

/*
	Major thanks go to Nate True for pointing me towards the (constructor) bit 
	and giving a bit of guidance to running inside SpringBoard.
 
	Also, to Saurik for providing MobileSubstrate and the Winterboard source
	that enabled me to do everything you see in Stack 2.0. Without that, 
	there would be no Stack 2.0.
 
 */

#import <UIKit/UIKit.h>
#import <GraphicsServices.h>
#import "MobileStack.h"

#import <execinfo.h>
#import <signal.h>
//
//void _stack_SpringBoard_CrashHandler()
//{
//	//UIAlertView *_infoSheet = [[UIAlertView alloc] initWithTitle:@"Rats!" message:@"Stack has encountered an error and has had to close. You will need to restart your device to reactivate Stack." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////	[_infoSheet show];
//	
//	NSLog(@"Stack has detected a SpringBoard crash. Quitting with the option of disabling Stack.");
//	
//	NSString *__crashHandlerCheck = [NSString stringWithContentsOfFile:@"/tmp/stack_crash.txt"];
//	
//	if (__crashHandlerCheck && [__crashHandlerCheck isEqualToString:@"warnOnStackEntry"])
//	{
//		[@"preventStackEntry" writeToFile:@"/tmp/stack_crash.txt" atomically:NO];
//	}
//	else
//		[@"warnOnStackEntry" writeToFile:@"/tmp/stack_crash.txt" atomically:NO];
//	
//	[[UIApplication sharedApplication] terminate];
//	return;
//}

//__attribute__((constructor)) static 

#if 0
__attribute__((constructor))
static Stack2Initializer()
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	if (![[[NSBundle mainBundle] bundleIdentifier] hasSuffix: @"springboard"])
	{
		return;
	}
	
	NSLog(@"MobileStack did inject");
	
	
	
	
	[[MobileStack sharedInstance] performSelectorOnMainThread: @selector(didInjectIntoProgram) withObject: nil waitUntilDone:NO];
	
		
	[pool release];
}
#endif
