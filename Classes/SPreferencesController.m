//
//  MobileStackPreferencesRootController.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 02/12/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

#import "SPreferencesController.h"

@implementation SPreferencesController

-(void)setStackPosition:(id)value specifier:(id)specifier {
	//[self setPreferenceValue:value specifier:specifier];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	
	/*
	
	if(value == kCFBooleanTrue){
		if(!doubletap){
			[self insertSpecifier:[specArray objectAtIndex:2] afterSpecifier:specifier animated:YES];
			doubletap = TRUE;
		}
	} else {
		[self removeSpecifier:[specArray objectAtIndex:2] animated:YES];
		doubletap = FALSE;
	}*/
	
	if (notify_post("com.steventroughtonsmith.stack.settingschanged")) {
		printf("Notification failed.\n"); exit(-1);
	}
	
	NSLog(@"notification posted");
}

#if 0
- (id)initForContentSize:(CGSize)s
{
	if (!self)
		self = [super initForContentSize:s];
	return self;
}


- (void)viewWillBecomeVisible:(void *)fp8
{
	[super viewWillBecomeVisible:fp8];
}


- (NSArray *)specifiers {
	NSArray *s = [self loadSpecifiersFromPlistName:@"Stack" target: self];
	
	NSLog([s description]);
//	s = [self localizedSpecifiersForSpecifiers:s];
	//specArray = [[NSArray alloc] initWithArray:s];
	return s;
}

-(void)setCurvedStack:(id)value specifier:(id)specifier
{
	//NSDictionary *stackPrefs = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath]];
//	if (!stackPrefs)
//		stackPrefs = [NSMutableDictionary dictionary];
//	[stackPrefs setValue:[NSNumber numberWithBool:value] forKey:@"UseCurvedStack"];
//	
//	[stackPrefs writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.plist" stringByExpandingTildeInPath] atomically:NO];
	
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if(value == kCFBooleanTrue){
		if(!doubletap){
			[self insertSpecifier:[specArray objectAtIndex:2] afterSpecifier:specifier animated:YES];
			doubletap = TRUE;
		}
	} else {
		[self removeSpecifier:[specArray objectAtIndex:2] animated:YES];
		doubletap = FALSE;
	}
	 
}
#endif

@end