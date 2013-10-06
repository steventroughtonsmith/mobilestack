//
//  SBStackRenameAlertDelegate.m
//  MobileStack
//
//  Created by Steven on 27/06/2009.
//  Copyright 2009 Steven Troughton-Smith. All rights reserved.
//

#import "SBStackRenameAlertDelegate.h"


@implementation SBStackRenameAlertDelegate

- (void) _alertSheetTextFieldReturn:(id)v	 	
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SBStackIconRename" object:[(UITextField *)v text]];

}


/*
- (BOOL)respondsToSelector:(SEL)aSelector

{
	NSLog(@"SBStackIcon: SEL = %@", NSStringFromSelector(aSelector));
	
	return NO;
}
*/

- (BOOL)alertSheet:(UIAlertView *)alertView buttonClicked:(NSInteger)buttonIndex
{
	if (buttonIndex == 2)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SBStackIconRename" object:[[alertView textField] text]];
	}
	
	[alertView dismiss];
}

@end
