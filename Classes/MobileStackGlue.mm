//
//  MobileStackGlue.m
//  MobileStack
//
//  Created by Steven Troughton-Smith on 23/08/2008.
//  Copyright 2008 Steven Troughton-Smith. All rights reserved.
//

#import "MobileStack.h"
#import "MobileStackGlue.h"

#ifndef GRAPHICSSERVICES_H
#import <GraphicsServices.h>
#endif

#import <SBIcon.h>

#pragma mark -
#pragma mark Substrate Code

#define WBPrefix "stack_"

bool Debug_ = false;
bool Engineer_ = false;

void WBRename_stack_(bool instance, const char *classname, const char *oldname, IMP newimp) {
    Class _class = objc_getClass(classname);
    if (_class == nil) {
        if (Debug_)
            NSLog(@"WB:Warning: cannot find class [%s]", classname);
        return;
    }
    if (!instance)
        _class = object_getClass(_class);
    Method method = class_getInstanceMethod(_class, sel_getUid(oldname));
    if (method == nil) {
        if (Debug_)
            NSLog(@"WB:Warning: cannot find method [%s %s]", classname, oldname);
        return;
    }
    size_t namelen = strlen(oldname);
    char newname[sizeof(WBPrefix) + namelen];
    memcpy(newname, WBPrefix, sizeof(WBPrefix) - 1);
    memcpy(newname + sizeof(WBPrefix) - 1, oldname, namelen + 1);
    const char *type = method_getTypeEncoding(method);
    if (!class_addMethod(_class, sel_registerName(newname), method_getImplementation(method), type))
        NSLog(@"WB:Error: failed to rename [%s %s]", classname, oldname);
    unsigned int count;
    Method *methods = class_copyMethodList(_class, &count);
    for (unsigned int index(0); index != count; ++index)
        if (methods[index] == method)
            goto found;
    if (newimp != NULL)
        if (!class_addMethod(_class, sel_getUid(oldname), newimp, type))
            NSLog(@"WB:Error: failed to rename [%s %s]", classname, oldname);
    goto done;
found:
    if (newimp != NULL)
        method_setImplementation(method, newimp);
done:
    free(methods);
}

#pragma mark -
#pragma mark Simulator Theme Support (Internal)

#define ENABLE_SIMULATOR_THEMES 0

#if ENABLE_SIMULATOR_THEMES

@protocol WinterBoard
@end

NSString *theme = @"/Deep";

static NSString * SBApplication$pathForIcon(id<WinterBoard> *self, SEL sel) {

	NSString *identifier = [self displayIdentifier];
	
	if (identifier != nil) {
		NSString *path = [NSString stringWithFormat:@"%@/Bundles/%@/icon.png", theme, identifier];

		return path;
	}
	
    return [self stack_pathForIcon];
}
#endif

#pragma mark -
#pragma mark Protocol

@protocol Stack
- (void)stack_noteGrabbedIconLocationChangedWithEvent:(GSEvent *)event;
- (void)stack_noteGrabbedIconLocationChangedWithTouch:(UITouch *)touches;

@end

#pragma mark -
#pragma mark In-house code

static void MobileStackSBDraggingIcon(id<Stack> self, SEL sel, GSEvent * event) 
{
	CGPoint grabbedIconLocation = GSEventGetLocationInWindow(event);
	
	SBIcon *_grabbedIcon;
	object_getInstanceVariable(self, "_grabbedIcon", (void **)&_grabbedIcon);
	
	NSLog(@"grabrect = %@\n location = %@", NSStringFromCGRect([[MobileStack sharedInstance] _stackDragRect]), NSStringFromCGPoint(grabbedIconLocation));

	if (CGRectContainsPoint([[MobileStack sharedInstance] _stackDragRect], grabbedIconLocation))
	{
		
		if ([NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBBookmarkIcon"] || [NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBDownloadingIcon"])
		{
			
			// FIXME: Oh, hackety hack hack hack
			
		}
		else
		{
			NSLog(@"Should add %@ to Stack, %@", [_grabbedIcon displayName], [_grabbedIcon displayIdentifier]);
			[[MobileStack sharedInstance] addItemToStack:[_grabbedIcon displayIdentifier]];
			[[MobileStack sharedInstance] openStack:nil];
		}
		
		return;
		
	}
	else
	{	
		[[MobileStack sharedInstance] closeStack:nil];
	}
	
	[self stack_noteGrabbedIconLocationChangedWithEvent:event];
}


static void MobileStackSBDraggingIcon30(id<Stack> self, SEL sel, UITouch * touch) 
{
	CGPoint grabbedIconLocation = [touch locationInView:nil];
	
	SBIcon *_grabbedIcon;
	object_getInstanceVariable(self, "_grabbedIcon", (void **)&_grabbedIcon);
	
	//NSLog(@"grabrect = %@\n location = %@", NSStringFromCGRect([[MobileStack sharedInstance] _stackDragRect]), NSStringFromCGPoint(grabbedIconLocation));
	
	if (CGRectContainsPoint([[MobileStack sharedInstance] _stackDragRect], grabbedIconLocation))
	{
		
		if ([NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBBookmarkIcon"] || [NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBDownloadingIcon"])
		{
			
			// FIXME: Oh, hackety hack hack hack
			
		}
		else
		{
			NSLog(@"Should add %@ to Stack, %@", [_grabbedIcon displayName], [_grabbedIcon displayIdentifier]);
			[[MobileStack sharedInstance] addItemToStack:[_grabbedIcon displayIdentifier]];
			[[MobileStack sharedInstance] openStack:nil];
		}
		
		return;
		
	}
	else
	{	
		[[MobileStack sharedInstance] closeStack:nil];
	}
	
	[self stack_noteGrabbedIconLocationChangedWithTouch:touch];
}

//void InstallMobileStackSettingsBundle()
//{
//	NSDictionary *_currentSettings_iPhone = [NSDictionary dictionaryWithContentsOfFile:@"/Applications/Preferences.app/Settings-iPhone.plist"];
//	
//	NSLog(@"InstallMobileStackSettingsBundle()");
//	
//	if (!_currentSettings_iPhone)
//	{
//		NSLog(@"Serious failure in InstallMobileStackSettingsBundle()");
//		return;
//	}
//	
//	NSMutableDictionary *_newSettings_iPhone = [NSMutableDictionary dictionaryWithDictionary:_currentSettings_iPhone];
//	NSMutableArray *_items = [NSMutableArray arrayWithArray:[_currentSettings_iPhone objectForKey:@"items"]];
//	
//	for (NSDictionary *_temp in _items)
//	{
//		if ([[_temp objectForKey:@"bundle"] isEqualToString:@"MobileStackSettings"]) // Already installed
//			return;
//	}
//	
//	NSDictionary *_beginGroup = [NSDictionary dictionaryWithObject:@"PSGroupCell" forKey:@"cell"];
//	NSDictionary *_payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"MobileStackSettings", @"PSLinkCell", [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], @"Stack", nil] forKeys:[NSArray arrayWithObjects:@"bundle", @"cell", @"hasIcon", @"isController", @"label", nil ]];	
//	NSDictionary *_endGroup = [NSDictionary dictionaryWithObject:@"PSGroupCell" forKey:@"cell"];
//
//	[_items addObject:_beginGroup];
//	[_items addObject:_payload];
//	[_items addObject:_endGroup];
//	
//	[_newSettings_iPhone setObject:_items forKey:@"items"];
//	[_newSettings_iPhone writeToFile:@"/Applications/Preferences.app/Settings-iPhone.plist" atomically:YES];
//
//	NSLog(@"InstallMobileStackSettingsBundle() Completed");
//}

void MobileStackEngineInitialize()
{
	NSLog(@"Stack Init and return");
	
	
	//[NSClassFromString(@"SBIconController") sharedInstance]
	
	//Class SBStackIcon = NSClassFromString(@"SBStackIcon");
	
	 //[[NSClassFromString(@"SBStackIcon") alloc] init];
   // [o foo];

	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.0) /* iPhone 3.0 API Change */
	WBRename_stack_(true, "SBIconController", "noteGrabbedIconLocationChangedWithEvent:", (IMP) &MobileStackSBDraggingIcon);
	else
	WBRename_stack_(true, "SBIconController", "noteGrabbedIconLocationChangedWithTouch:", (IMP) &MobileStackSBDraggingIcon30);

#if ENABLE_SIMULATOR_THEMES
	WBRename_stack_(true, "SBApplication", "pathForIcon", (IMP) &SBApplication$pathForIcon);
#endif
}
