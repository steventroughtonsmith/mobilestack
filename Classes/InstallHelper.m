/*
 *  InstallHelper.m
 *  MobileStack
 *
 *  Created by Steven Troughton-Smith on 06/12/2008.
 *  Copyright 2008 Steven Troughton-Smith. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

void insertPrefBundle(NSString *settingsFile) {
	int i;
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile: settingsFile];
	for(i = 0; i < [[settings objectForKey:@"items"] count]; i++) {
		NSDictionary *entry = [[settings objectForKey:@"items"] objectAtIndex: i];
		if([[entry objectForKey:@"bundle"] isEqualToString:@"MobileStackSettings"]){
			return;
		}
	}
	[[settings objectForKey:@"items"] insertObject: [NSDictionary dictionaryWithObjectsAndKeys: @"PSLinkCell", @"cell", @"MobileStackSettings", @"bundle",	@"Stack", @"label", [NSNumber numberWithInt:1], @"isController", [NSNumber numberWithInt:1], @"hasIcon", nil] atIndex: [[settings objectForKey:@"items"] count] - 1];
	[settings writeToFile:settingsFile atomically:YES];
}

void removePrefBundle(NSString *settingsFile) {
	int i;
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsFile];
	for(i = 0; i < [[settings objectForKey:@"items"] count]; i++) {
		NSDictionary *entry = [[settings objectForKey:@"items"] objectAtIndex: i];
		if([[entry objectForKey:@"bundle"] isEqualToString:@"MobileStackSettings"]) {
			[[settings objectForKey:@"items"] removeObjectAtIndex: i];
		}
	}
	[settings writeToFile:settingsFile atomically:YES];
}

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if(argc > 1 && !strcmp(argv[1],"--installPrefBundle")) {
#if TARGET_IPHONE_SIMULATOR
		insertPrefBundle(@"/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator3.0.sdk/Applications/Preferences.app/Settings-Simulator.plist");
#else
		insertPrefBundle(@"/Applications/Preferences.app/Settings-iPhone.plist");
		insertPrefBundle(@"/Applications/Preferences.app/Settings-iPod.plist");
#endif
		return 0;
	} else if(argc > 1 && !strcmp(argv[1],"--removePrefBundle")) {
#if TARGET_IPHONE_SIMULATOR
		removePrefBundle(@"/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator3.0.sdk/Applications/Preferences.app/Settings-Simulator.plist");

#else
		removePrefBundle(@"/Applications/Preferences.app/Settings-iPhone.plist");
		removePrefBundle(@"/Applications/Preferences.app/Settings-iPod.plist");
#endif
		return 0;
	}
	
	[pool drain];
	return 0;
}