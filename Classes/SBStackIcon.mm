//
//  SBStackIcon.m
//  SBStackIcon
//
//  Created by Steven on 23/06/2009.
//  Copyright 2009 Steven Troughton-Smith. All rights reserved.
//

#import "SBStackIcon.h"
#import "SBStackRenameAlertDelegate.h"
#import <notify.h>

int notification_token;
#define STACK_PREFS_PATH @"/User/Library/Preferences/com.steventroughtonsmith.stack.plist"
#define MULTIPLIER (-3)
#define BUTTON_HEIGHT (70.0)

#define DELTA 60.0f
#define STACK_CASCADE_DELTA 3.0f

SBIconList *_currentIconList = nil;

int _savedX = -1;
int _savedY = -1;

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
#pragma mark Protocol

@protocol Stack
//- (void)stack_noteGrabbedIconLocationChangedWithEvent:(GSEvent *)event;
- (void)stack_noteGrabbedIconLocationChangedWithTouch:(UITouch *)touches;
- (void)stack_updateCurrentIconListIndex;
- (void)stack_statusBarClicked;

@end



#pragma mark -
static void MobileStackSBupdateCurrentIconListIndex30(id<Stack> self, SEL sel) 
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SBStackIconChangedPage" object:self];
	
	[self stack_updateCurrentIconListIndex];
}

static void MobileStackstatusBarClicked(id<Stack> self, SEL sel) 
{
	
	NSLog(@"SBStackIcon: showDoubleHeight");
	
	SBStatusBarController *c = [NSClassFromString(@"SBStatusBarController") sharedStatusBarController];
	
	
	if ([[c doubleHeightPrefixText] isEqualToString:@"Touch here to rename this Stack"])
	{
		
#if RENAME_WORKING
		SBIconController *ic = [NSClassFromString(@"SBIconController") sharedInstance];
		[ic setIsEditing:NO];
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Rename Stack" message:nil delegate:[SBStackIcon sharedRenameAlertDelegate] cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		
		[av addTextFieldWithValue:@"" label:@"Stack"];
		
		[av show];	
		[av release];
		
		//[[UIKeyboard automaticKeyboard] orderInWithAnimation:YES];
#else
		UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Alpha Limitation!" message:@"Sorry, can't rename the Stack just yet. Check back later." delegate:self cancelButtonTitle:@"Rats!" otherButtonTitles:nil];
		[v show];
		[v release];	
#endif
		
	}
	else
		[self stack_statusBarClicked];
}

static void MobileStackSBDraggingIcon30(id<Stack> self, SEL sel, UITouch * touch) 
{
	CGPoint grabbedIconLocation = [touch locationInView:nil];
	
	SBIcon *_grabbedIcon;
	object_getInstanceVariable(self, "_grabbedIcon", (void **)&_grabbedIcon);
	
	if ([NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBStackIcon"])
	{
		[self stack_noteGrabbedIconLocationChangedWithTouch:touch];
		return;
	}
	
	//NSLog(@"grabrect = %@\n location = %@", NSStringFromCGRect([[SBStackIcon sharedInstance] _stackDragRect]), NSStringFromCGPoint(grabbedIconLocation));
	
	//CGPoint();
	
	if (CGRectContainsPoint([[SBStackIcon sharedInstance] _stackDragRect], grabbedIconLocation))
	{
		
		if ([NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBBookmarkIcon"] || [NSStringFromClass([_grabbedIcon class]) isEqualToString:@"SBDownloadingIcon"])
		{
			
			// FIXME: Oh, hackety hack hack hack
			
		}
		else
		{
			NSLog(@"Should add %@ to Stack, %@", [_grabbedIcon displayName], [_grabbedIcon displayIdentifier]);
			[[SBStackIcon sharedInstance] addItemToStack:[_grabbedIcon displayIdentifier]];
			[[SBStackIcon sharedInstance] openStack:nil];
		}
		
		return;
		
	}
	else
	{	
		[[SBStackIcon sharedInstance] closeStack:nil];
	}
	
	[self stack_noteGrabbedIconLocationChangedWithTouch:touch];
}

#pragma mark -

__attribute__((constructor))
static void Stack3Initializer()
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if (![[[NSBundle mainBundle] bundleIdentifier] hasSuffix: @"springboard"])
	{
		return;
	}
	
	NSLog(@"Status: SBStackIcon did inject");
	
	class_setSuperclass( NSClassFromString(@"SBStackIcon"),  NSClassFromString(@"SBIcon"));
	NSLog(@"Status: SBStackIcon: really set super");
	
	
	NSLog(@"Status: SBStackIcon: Stack3Initializer()");
	NSLog(@"Status: SBStackIcon: initialize");
	
	WBRename_stack_(true, "SBIconController", "noteGrabbedIconLocationChangedWithTouch:", (IMP) &MobileStackSBDraggingIcon30);
	WBRename_stack_(true, "SBIconController", "updateCurrentIconListIndex", (IMP) &MobileStackSBupdateCurrentIconListIndex30);
	WBRename_stack_(true, "SBStatusBar", "statusBarClicked", (IMP) &MobileStackstatusBarClicked);
	
	NSLog(@"Status: SBStackIcon: WBRename_stack_");
	
	//Class k = NSClassFromString(@"SBStackIcon");
    //class_setSuperclass(k, NSClassFromString(@"SBIcon"));
	
	//class_setSuperclass( NSClassFromString(@"SBStackIcon"),  NSClassFromString(@"SBIcon"));
	
	NSLog(@"SBStackIcon: class_setSuperclass");
	
	
	SBStackIcon *stackIcon = [SBStackIcon sharedInstance];
	
	/*
	 SBStackIcon *stackIconTwo = [[SBStackIcon alloc] initWithDefaultSize];
	 SBStackIcon *stackIconThree = [[SBStackIcon alloc] initWithDefaultSize];
	 SBStackIcon *stackIconFour = [[SBStackIcon alloc] initWithDefaultSize];
	 */		
	//[ performSelectorOnMainThread: @selector(setIconToInstall:) withObject: stackIcon waitUntilDone:NO];
	
	
	
	
	[pool release];
	
}

static SBStackRenameAlertDelegate *sharedRenameAlertDelegate = nil;
static SBStackIcon *sharedInstance = nil;
BOOL stackOpen = NO;
BOOL useCurvedStack = YES;
BOOL forceGridView = NO;
CGFloat timescale = 0.3f;
BOOL __isClosingFromFan = NO;
BOOL forceGridViewFromIconList = NO;
BOOL _isShowingAlert = NO;

NSString *_stackTitle = @"Stack";

@implementation SBStackIcon

+ (SBStackIcon *) sharedInstance
{
	if (sharedInstance == nil) 
	{		
		[[SBStackIcon alloc] performSelector:@selector(initWithDefaultSize) withObject:nil afterDelay:1.0];
	}
	return sharedInstance;
}

+ (SBStackRenameAlertDelegate *) sharedRenameAlertDelegate
{
	if (sharedRenameAlertDelegate == nil) 
	{		
		sharedRenameAlertDelegate = [[[SBStackRenameAlertDelegate alloc] init] retain];
	}
	return sharedRenameAlertDelegate;
}

-(CGRect)_stackDragRect
{	
	return [[self superview] convertRect:[self frame] toView:nil];//CGRectMake([self stackPosition], 480-70, 70, 70);
}

-(void)insertSelf
{
	return;
	if ([self superview] != nil)
		return;
	
	
#if 0
	if (_currentIconList != nil)
	{
		int x = -1, y = -1;
		
		NSLog(@"SBStackIcon: About to insert on %@", _currentIconList.description);
		
		if (_savedX == -1 || _savedY == -1)
		{
			if (![_currentIconList firstFreeSlotX:&x Y:&y])
				return;
		}
		else {
			x = _savedX;
			y = _savedY;
		}
		
		NSLog(@"SBStackIcon: About to insert at %i,%i on %@", x, y, _currentIconList.description);
		
		[_currentIconList placeIcon:self atX:x Y:y animate:YES moveNow:YES];
		[_currentIconList layoutIconsNow];
		_currentIconList = nil;
		return;
	}
#endif
	
	id uiC = [NSClassFromString(@"SBUIController") sharedInstance];
	
	//UIView *_buttonBarContainerView;
	SBIconList *list;
	
	/*
	 object_getInstanceVariable(uiC, "_buttonBarContainerView", (void **)&_buttonBarContainerView);
	 
	 for (UIView *v in [_buttonBarContainerView subviews])
	 {
	 if ([[v class] isSubclassOfClass:NSClassFromString(@"SBIconList")])
	 {
	 NSLog(@"SBStackIcon: Found Dock List");
	 list = v;
	 }
	 }
	 
	 if (!list)
	 return;*/
	
#if 0
	NSInteger x = -1, y = -1;
	
	SBIconList *l = [[NSClassFromString(@"SBIconModel") sharedInstance] buttonBar];
	
	if ([l firstFreeSlotX:&x Y:&y])
		[l placeIcon:self atX:x Y:y animate:YES moveNow:YES];
	[l layoutIconsNow];
	
#endif
#if 0
	for (SBIconList *l in [[NSClassFromString(@"SBIconModel") sharedInstance] iconLists])
	{
		if ([l firstFreeSlotX:&x Y:&y])
		{
			[l placeIcon:self atX:x Y:y animate:YES moveNow:YES];
			[l layoutIconsNow];
			break;
		}
	}
#endif
	
#if 1
	Class SBApplicationController = objc_getClass("SBApplicationController");
	SBApplicationController *appController = [SBApplicationController sharedInstance];
	
	SBApplication *currentApp = [appController applicationWithDisplayIdentifier:@"com.steventroughtonsmith.stackdummy"];
	
	if (currentApp)
	{
		
		NSLog(@"SBStackIcon: Test = %@", [[[NSClassFromString(@"SBIconModel") sharedInstance] iconForDisplayIdentifier:@"com.steventroughtonsmith.stackdummy"] description]);
		//[[NSClassFromString(@"SBIconModel") sharedInstance] uninstallApplicationIcon:currentApp];
		//[[NSClassFromString(@"SBIconModel") sharedInstance] addIconForApplication:currentApp];
		
	}
#endif
	
	//[self addIconToStack:[list iconAtX:x Y:y]];
	
	
	//_currentIconList = list;
	//[[NSClassFromString(@"SBIconController") sharedInstance]
	
	//[[NSClassFromString(@"SBIconController") sharedInstance] setIconToInstall:self];
	
	
	//addNewIconToDesignatedLocation:self animate:NO scrollToList:NO saveIconState:YES];
	//[[NSClassFromString(@"SBIconModel") sharedInstance]  noteIconStateChangedExternally];
	
	//addNewIconToDesignatedLocation
	
}

#pragma mark Housekeeping

-(void)addIconToStack:(SBIcon *)icon
{
	//[self addItemToStack:[icon displayIdentifier]];
}

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
	[self addSubview:currentButton];
	[currentButton release];
	
	[buttonStoreArray writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath]  atomically:YES];
}

-(void)removeFromSuperview
{
	if ([self superview])
		NSLog(@"SBStackIcon: Removed from SuperView on %@", [self superview].description);
	
	//_currentIconList = (SBIconList *)[self superview];	
	//[_currentIconList getX:&_savedX Y:&_savedY forIcon:self];
	
	//NSLog(@"SBStackIcon: Removed from %i, %i on %@", _savedX, _savedY, [self superview].description);
	
	
	[super removeFromSuperview];
	[self performSelectorOnMainThread:@selector(insertSelf) withObject:nil waitUntilDone:NO];
	
}



-(void)notification_thread
{
	int was_posted;
	
	NSLog(@"SBStackIcon: Notification thread active");
	
	while (1) {
		//sleep(1);
		[NSThread sleepForTimeInterval:1.0];
		
		if (notify_check(notification_token, &was_posted)) {
			NSLog(@"SBStackIcon: Call to notify_check failed."); exit(-1);
		}
		if (was_posted) {
			/* The notification org.apache.httpd.configFileChanged
			 was posted. */
			
			//[[MobileStack sharedInstance] _settingsChanged];
			NSLog(@"SBStackIcon: Notification %d was posted.", notification_token);
			
			if (notification_token == 92 || notification_token == 90)
			{
				[NSThread sleepForTimeInterval:1.0];
				[self performSelectorOnMainThread:@selector(insertSelf) withObject:nil waitUntilDone:NO];
			}
		}
	}
	
}

- (id) initWithDefaultSize
{
	self = [(SBIcon *)super initWithDefaultSize];
	if (self != nil) {
		sharedInstance = self;
		NSLog(@"SBStackIcon: stack icon init");
		[self initStackPrefs];
		
#if 1
		NSLog(@"self superclass = %@", NSStringFromClass([self superclass]));
		[self performSelectorOnMainThread:@selector(setupStack) withObject:nil waitUntilDone:YES];;
		//[self performSelector:@selector(insertSelf) withObject:nil afterDelay:1.0];
		//	[self performSelector:@selector(insertSelf) withObject:nil afterDelay:1.0];
		[self performSelectorOnMainThread:@selector(insertSelf) withObject:nil waitUntilDone:YES];//:@selector(insertSelf) withObject:nil afterDelay:1.0];
#else
		[self performSelectorOnMainThread:@selector(setupStack) withObject:nil waitUntilDone:YES];;
#endif
		//notify_register_check("com.apple.mobile.application_installed", &notification_token);
		
		//[self performSelectorInBackground:@selector(notification_thread) withObject:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repaginationNotificationReceived:) name:@"SBStackIconChangedPage" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameNotificationReceived:) name:@"SBStackIconRename" object:nil];
		
		//[self setFrame:CGRectMake(0,0, [NSClassFromString(@"SBIcon") defaultIconSize].width, [NSClassFromString(@"SBIcon") defaultIconSize].height)];
		//[self insertSelf];
	}
	
	return self;
	//[[NSRunLoop mainRunLoop] performSelector:@selector(initWithDefaultSize) target:self argument:nil order:0 modes:nil];
	
}

- (id)displayIdentifier
{
	return @"com.steventroughtonsmith.stackdummy";
}

- (BOOL)allowJitter
{
	return NO;
}

+ (BOOL)isKindOfClass:(Class)theClass
{
	if (theClass == NSClassFromString(@"SBIcon"))
		return YES;
	
	return NO;
}

-(UIImage *)icon
{
#if 1
	CGSize s = [NSClassFromString(@"SBIcon") defaultIconSize];
	UIGraphicsBeginImageContext(s);
	
	[[UIImage imageWithContentsOfFile:@"/Library/SBStackIcon/stack_drawer_button_single.png"] drawInRect:CGRectMake(0, 14, 59, 60) blendMode:kCGBlendModeDestinationOver alpha:1.0];
	
	
	/*
	 [[UIColor redColor] set];
	 UIRectFill(CGRectMake(0,0,s.width, s.height));
	 */
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
#endif
	
	
	return image;
	
}

#if 0
-(void)drawRect:(CGRect)rect
{
	[[UIColor greenColor] set];
	UIRectFill(rect);
}
#endif

- (id)tags
{
	return nil;
}

-(void)renameNotificationReceived:(NSNotification *)note
{
	NSLog(@"SBStackIcon: renameNotificationReceived: %@", note.description);
	
	/*
	 UIAlertView * v = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Stack Renamed to '%@'", [note object]] message:@"One moment while your changes are made" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	 [v show];
	 [v release];
	 
	 _isShowingAlert = YES;*/
	
	
	_stackTitle = [note object];	
	[self writeNewName];
	
	//	[NSThread sleepForTimeInterval:3.0];
	
	//[[NSClassFromString(@"SBIconModel") sharedInstance] reloadIconImage:self];
	
	notify_post("com.apple.language.changed");
	
	//[self localeChanged];
}

-(BOOL)writeNewName
{
	NSMutableDictionary *_stackPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:STACK_PREFS_PATH];
	[_stackPrefs setValue:_stackTitle forKey:@"StackTitle"];
	return [_stackPrefs writeToFile:STACK_PREFS_PATH atomically:YES];
	
}

-(void)repaginationNotificationReceived:(NSNotification *)note
{
	//NSLog(@"SBStackIcon: Unkown Notification: %@", note.description);
	
	SBIconController * c = [note object];
	
	if ((int)[c currentIconListIndex] == -1)
	{
		[self closeStack:self]; 
		//stackWindow.alpha = 0.0;
	}
	
}


-(NSString *)displayName
{
	
	NSMutableDictionary *_stackPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:STACK_PREFS_PATH];
	NSString *newTitle = [_stackPrefs valueForKey:@"StackTitle"];
	
	if (newTitle)
		return newTitle;
	else
		return _stackTitle;
}


BOOL _isDoubleHeight = NO;

- (void)setIsGrabbed:(BOOL)fp8
{
	if (fp8)
	{
		[self showDoubleHeight];	
	}
	else
	{
		
		[self performSelector:@selector(hideDoubleHeight) withObject:nil afterDelay:2.0];
		
	}
	
	[super setIsGrabbed:fp8];
}

-(void)showDoubleHeight
{
	
	NSLog(@"SBStackIcon: showDoubleHeight");
	
	SBStatusBarController *c = [NSClassFromString(@"SBStatusBarController") sharedStatusBarController];
	
	
	[c setDoubleHeightMode:2 glowAnimationEnabled:YES bundleID:@"com.steventroughtonsmith.stack"];
	[c setDoubleHeightPrefixText:@"Touch here to rename this Stack" bundleID:@"com.steventroughtonsmith.stack"];
	//[c setDoubleHeightStatusText:@"Tap here to rename this Stack" bundleID:@"com.steventroughtonsmith.stack"];
	
	//[c setStatusBarMode:1<<4 orientation:0 duration:timescale animation:0];
	//resizeStatusBar:40 grow:YES fenceID:nil];
}

-(void)hideDoubleHeight
{
	NSLog(@"SBStackIcon: hideDoubleHeight");
	
	SBStatusBarController *c = [NSClassFromString(@"SBStatusBarController") sharedStatusBarController];
	
	[c setDoubleHeightMode:0 glowAnimationEnabled:NO bundleID:@"com.steventroughtonsmith.stack"];
	
}


-(void)launch
{
	NSLog(@"SBStackIcon: launch");
	
	NSLog(@"Class = %@", NSStringFromClass([[self superview] class]));
	
	if ([[[self superview] class] isEqual:NSClassFromString(@"SBButtonBar")])
	{
		forceGridViewFromIconList = NO; 
	}
	
	else
	{
		/*
		 UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Alpha Limitation!" message:@"Sorry, can't do that yet. Please place me in the Dock." delegate:self cancelButtonTitle:@"Rats!" otherButtonTitles:nil];
		 [v show];
		 [v release];*/
		
		forceGridViewFromIconList = YES;
		
	}
	
	[self showStack:self];
	
	/*buttonStoreArray = [[NSMutableArray arrayWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath]] retain];
	 NSLog(@"SBStackIcon: Button array = set");
	 */
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

- (void) showStack:(id) event
{
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
	
	if (forceGridViewFromIconList || [[stackPrefs valueForKey:@"ForceGridView"] boolValue] == YES)
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
			[self performSelectorOnMainThread:@selector(_closeGridView_old) withObject:nil waitUntilDone:YES];
		}
		else
		{
			[self performSelectorOnMainThread:@selector(_closeFanView) withObject:nil waitUntilDone:YES];
			
		}
		for (MobileStackButton *currentButton in buttonArray)
		{
			[currentButton setEnabled:NO];
		}	
		
		[toggleStackButton setEnabled:NO];
	}
	/*
	 * opening stack
	 */
	else
	{		
		if ([buttonArray count] > 5 || forceGridView)	// Grid View!
		{		
			[self performSelectorOnMainThread:@selector(_openGridView_old) withObject:nil waitUntilDone:YES];
			
		}
		else							// Fan View!
		{
			[self performSelectorOnMainThread:@selector(_openFanView) withObject:nil waitUntilDone:YES];
			
		}	
		
		/* Enable all buttons */
		
		for (MobileStackButton *currentButton in buttonArray)
		{
			[currentButton setEnabled:YES];
		}	
		[toggleStackButton setEnabled:YES];
	}
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark StackCode

-(void)createDefaultButtonStore
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

-(void)setupStack
{
	
	CGRect rect = [UIScreen mainScreen].bounds;
	
	stackWindow = [[[UIWindow alloc] initWithFrame:CGRectMake([self stackPosition], rect.size.height-75-STACK_CASCADE_DELTA, 60.0f, 90.0f)] retain];
	
	roundrectView = [[[SGridView alloc] initWithFrame: [stackWindow bounds]] retain];
	
#if 0
	stackWindow.backgroundColor = [UIColor blueColor];
#endif
	
	/* Customization Code here */
	/* Load the Stack entries from the file, or if there are none init with the default three and write it to disk */
	
	buttonStoreArray = [[NSMutableArray arrayWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.entries.plist" stringByExpandingTildeInPath]] retain];
	NSLog(@"SBStackIcon: Button array = set");
	
	if (!buttonStoreArray)
	{
		[self createDefaultButtonStore];
	}
	
	buttonArray = [[NSMutableArray array] retain];
	
	NSLog(@"SBStackIcon: About to setup buttons");
	
	
	Class SBApplicationController = NSClassFromString(@"SBApplicationController");
	
	NSLog(@"SBStackIcon: class got");
	SBApplicationController *appController = [SBApplicationController sharedInstance];
	
	NSLog(@"SBStackIcon: About to setup buttons (really this time)");
	
	
	CGFloat xDelta = 5;
	CGFloat yDelta = -1;
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
		xDelta = 0;
	
    rect.origin.x = rect.origin.y = 0.0f;
	CGRect initialRect = CGRectMake(xDelta+0.0f, yDelta+0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(xDelta+STACK_CASCADE_DELTA, yDelta+STACK_CASCADE_DELTA+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(xDelta+0.0f, yDelta+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(xDelta+-STACK_CASCADE_DELTA, yDelta+0.0f, 59.0f, 60.0f);
	
	
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
					
					MobileStackButton *currentButton = [[[MobileStackButton alloc] initWithFrame:initialRect] retain];
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
	
	/* Disable all the buttons except the toggle button to prevent spurious app launches */
	
	for (MobileStackButton *currentButton in buttonArray)
	{
		[currentButton setEnabled:NO];
		
		[self addSubview:currentButton];
	}
	
	/* Create the Stack toggle button */
	
	toggleStackButton = [[[MobileStackButton alloc] initWithFrame:CGRectOffset(initialRect, -STACK_CASCADE_DELTA, 0)] retain];
	toggleStackButton.enabled = NO;
	[toggleStackButton addTarget:self action:@selector(showStack:) forControlEvents:UIControlEventTouchUpInside];
	toggleStackButton.adjustsImageWhenDisabled = NO;
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{
		
		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	
	[self addSubview:toggleStackButton];
	[stackWindow addSubview:roundrectView];
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
	
	BOOL __warnRemove, __stackPos, __grid, __curve, __titleString = NO;
	
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
		
		if ([_key isEqualToString:@"StackTitle"])
			__titleString = YES;
	}	
	
	if (!__warnRemove)
		[_stackPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"WarnOnRemove"];
	
	if (!__stackPos)
		[_stackPrefs setValue:@"br" forKey:@"StackPosition"];
	
	if (!__grid)
		[_stackPrefs setValue:[NSNumber numberWithBool:NO] forKey:@"ForceGridView"];
	
	if (!__curve)
		[_stackPrefs setValue:[NSNumber numberWithBool:YES] forKey:@"UseCurvedStack"];
	
	if (__titleString)
		_stackTitle = [_stackPrefs valueForKey:@"StackTitle"];
	
	
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
#pragma mark -

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
	
	NSLog(@"SBStackIcon: Ordering Window");
	[stackWindow makeKeyAndVisible];	
	NSLog(@"SBStackIcon: Ordered Window");
	
	/* Setup reference rect */
	
	CGRect initialRect = CGRectMake(DELTA, rect.size.height-70, 59.0f, 60.0f);
	
	/* Place Stack minimization button */
	
	[toggleStackButton setFrame:CGRectMake(DELTA, rect.size.height-60-1, 59.0f, 60.0f)];
	[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button.png"] forState:UIControlStateNormal];
	NSLog(@"SBStackIcon: Set Frames");
	
	/* Position all buttons on the starting rect */
	
	for (MobileStackButton *currentButton in buttonArray)
	{
		[stackWindow addSubview:currentButton];
		
		[currentButton setFrame:initialRect];
		currentButton.hidden = NO;
		currentButton.alpha = 1.0;
#if SHADOW_ENABLED
		
		currentButton._shadow.alpha = 1.0;
#endif
	}
	
	NSLog(@"SBStackIcon: Positioned Buttons");
	
	
	toggleStackButton.enabled = YES;
	
	[stackWindow addSubview:toggleStackButton];
	
	stackOpen = YES;
	NSLog(@"SBStackIcon: addedsubview");
	
	[stackWindow setFrame:CGRectMake([self stackPosition]-DELTA, 0.0f, 120.0f, rect.size.height+75.0f)];
	
	NSLog(@"SBStackIcon: stackPosition");
	
	//[contentView setFrame:CGRectMake(0.0f, 0.0f, [stackWindow frame].size.width, [stackWindow frame].size.height)];
	//[roundrectView setFrame:[stackWindow bounds]];
	
	NSLog(@"SBStackIcon: Set Framez");
	
	/* Setup initial end rect */
	
	CGRect currentEndRect = initialRect;
}

#pragma mark -
#pragma mark Fan View

-(void)_openFanView
{
	[self performSelectorOnMainThread:@selector(_setupOpen) withObject:nil waitUntilDone:YES];
	roundrectView.hidden = YES;
	
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
		
		//[[currentView _shadow] setCenter:[currentView center]];
		
		//	[[currentView _shadow] setCenter:CGPointMake(currentEndRect.origin.x+currentEndRect.size.width/2+5*m-1,  [[currentView _shadow] center].y-(5-m))];
		
		//[[currentView _shadow] setTransform:CGAffineTransformIdentity];
		
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
	roundrectView.hidden = YES;
	
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
	
	//CGFloat _thisY = 0;//stackWindow.frame.size.height-60;
	
	
	CGFloat _thisY =  rect.size.height-60.0f-1;
	
	CGFloat deltaX = 0.0;//5.0f;
	
	CGRect endRectOther = CGRectMake(deltaX+ DELTA+0.0f, _thisY+0.0f, 59.0f, 60.0f);
	CGRect endRect3 = CGRectMake(deltaX+DELTA+STACK_CASCADE_DELTA, _thisY+STACK_CASCADE_DELTA+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect endRect2 = CGRectMake(deltaX+DELTA+0.0f, _thisY+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect endRect1 = CGRectMake(deltaX+DELTA+-STACK_CASCADE_DELTA, _thisY+0.0f, 59.0f, 60.0f);
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	if ([buttonArray count] <= 5 && !forceGridView)
	{
#if 0
		[stackWindow setFrame:CGRectMake([self stackPosition], 0.0f, 59.0f, rect.size.height)];
#endif
		//[contentView setFrame:CGRectMake(0, 0, [stackWindow frame].size.width, [stackWindow frame].size.height)];
		//[roundrectView setFrame:[contentView bounds]];
		[toggleStackButton setFrame:endRectOther];//CGRectMake(0.0f, [stackWindow frame].size.height-[toggleStackButton frame].size.height, 59.0f, 60.0f)];			
	}
	
	//[roundrectView setNeedsDisplay];
	
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
	
#if 1
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
	
	
	//roundrectView.alpha = 0.0f;
	
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{
		
		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	else
		[toggleStackButton setImage:nil forState:UIControlStateNormal];
	
	
	
	/* ---End Animation Block--- */
	
	[UIView commitAnimations];
	
	
#if 0
	stackWindow.frame = CGRectMake([self stackPosition], rect.size.height-60.0f-1, 60.0f, 90.0f);
#endif
	__isClosingFromFan = YES;
	
	[self performSelector:@selector(hideStackWindow) withObject:nil afterDelay:timescale];
	
	
	stackOpen = NO;
	
}

#pragma mark -

#pragma mark -
#pragma mark Grid View

-(void)_openGridView
{
	[self performSelectorOnMainThread:@selector(_setupOpen) withObject:nil waitUntilDone:YES];
	NSLog(@"SBStackIcon: _openGridView");
	
	if (!roundrectView) {
		roundrectView = [[SGridView alloc] initWithFrame: [stackWindow bounds]];
	}
	
	CGRect rect = [self stackRect];
	
	/* Fill the screen with the grid */
	
	[stackWindow setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height+27)];
	[stackWindow addSubview:roundrectView];
	[roundrectView release];
	
	[roundrectView setFrame:stackWindow.frame];
	roundrectView.alpha = 1.0;
	roundrectView.hidden = NO;
	[roundrectView setNeedsDisplay];
	
	[toggleStackButton setFrame:CGRectMake([self stackPosition], [stackWindow frame].size.height-[toggleStackButton frame].size.height-32+4, [toggleStackButton frame].size.width, [toggleStackButton frame].size.height)];
	
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
	
	
	for (MobileStackButton *currentView in buttonArray)
	{
		[roundrectView addSubview:currentView];
	}
	
	
	NSLog(@"SBStackIcon: _openGridView about to anim");
	
	roundrectView.alpha = 0.0;
	roundrectView.transform = CGAffineTransformMakeScale(0.1, 0.1);
	
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	roundrectView.transform = CGAffineTransformIdentity;
	roundrectView.alpha = 1.0;
	[UIView commitAnimations];	
	NSLog(@"SBStackIcon: _openGridView commitAnimations");
	
}

-(void)_openGridView_old
{
	[self performSelectorOnMainThread:@selector(_setupOpen) withObject:nil waitUntilDone:YES];
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	CGRect rect = [self stackRect];
	
	/* Fill the screen with the grid */
	
	[stackWindow setFrame:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height+27)];
	//[contentView setFrame:CGRectMake(0, 5, [stackWindow frame].size.width, [stackWindow frame].size.height-5-32)];
	
	[roundrectView setFrame:stackWindow.frame];
	roundrectView.alpha = 1.0;
	roundrectView.hidden = NO;
	[roundrectView setNeedsDisplay];
	
	[toggleStackButton setFrame:CGRectMake([self stackPosition], [stackWindow frame].size.height-[toggleStackButton frame].size.height-32+4, [toggleStackButton frame].size.width, [toggleStackButton frame].size.height)];
	
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

-(void)_closeGridView_old
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
	
	
	CGRect endRectOther = CGRectMake(0.0f, rect.size.height-75-STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect endRect1 = CGRectMake(STACK_CASCADE_DELTA, rect.size.height-75, 59.0f, 60.0f);
	CGRect endRect2 = CGRectMake(0.0f,  rect.size.height-75-STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect endRect3 = CGRectMake(-STACK_CASCADE_DELTA, rect.size.height-75-STACK_CASCADE_DELTA-STACK_CASCADE_DELTA, 59.0f, 60.0f);
	
	/* ---Start Animation Block--- */
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	
	{
		[stackWindow setFrame:CGRectMake([self stackPosition], 0.0f, 59.0f, rect.size.height)];
		//[contentView setFrame:CGRectMake(0, 0, [stackWindow frame].size.width, [stackWindow frame].size.height)];
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
	roundrectView.hidden = YES;
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{
		
		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	else
		[toggleStackButton setImage:nil forState:UIControlStateNormal];
	
	/* ---End Animation Block--- */
	
	[UIView commitAnimations];
	
	stackWindow.frame = CGRectMake([self stackPosition], rect.size.height-60.0f-1, 60.0f, 90.0f);
	CGRect initialRect = CGRectMake(0.0f, 0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(STACK_CASCADE_DELTA, STACK_CASCADE_DELTA+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(0.0f, STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(-STACK_CASCADE_DELTA, 0.0f, 59.0f, 60.0f);
	
#if 0
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
	
#if 0//SHADOW_ENABLED
	for (MobileStackButton *currentButton in buttonArray)
	{
		[[currentButton _shadow] setCenter:currentButton.center];
	}
#endif		
	[toggleStackButton setFrame:initialRect];
#endif
	
	[self performSelector:@selector(hideStackWindow) withObject:nil afterDelay:timescale];
	
	stackOpen = NO;
	
}

-(void)_closeGridView
{
	NSLog(@"SBStackIcon: _closeGridView");
	
	[roundrectView setNeedsDisplay];
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:timescale]; 
	roundrectView.transform = CGAffineTransformMakeScale(0.1, 0.1);
	roundrectView.alpha = 0.0;
	[UIView commitAnimations];
	
	[self performSelector:@selector(hideStackWindow) withObject:nil afterDelay:timescale];
	
	stackOpen = NO;
}


#pragma mark -
-(void)hideStackWindow
{
	for (MobileStackButton *currentButton in buttonArray)
	{
		[self addSubview:currentButton];
	}
	
	[self addSubview:toggleStackButton];
	
	
	[stackWindow resignKeyWindow];
	
	//[roundrectView removeFromSuperview];
	toggleStackButton.enabled = NO;
	stackWindow.hidden = YES;
	//roundrectView.hidden = YES;
	
	
	CGFloat xDelta = 0;
	
	
	if (__isClosingFromFan )
	{
		__isClosingFromFan = NO;
		
		if (![[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
			
			xDelta = STACK_CASCADE_DELTA;
	}
	
	CGFloat deltay =  -1;//rect.size.height-60.0f-1;
	
	CGRect initialRect = CGRectMake(xDelta+0.0f, deltay+0.0f, 59.0f, 60.0f);
	CGRect initialRect1 = CGRectMake(xDelta+STACK_CASCADE_DELTA, deltay+STACK_CASCADE_DELTA+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect initialRect2 = CGRectMake(xDelta+0.0f, deltay+STACK_CASCADE_DELTA, 59.0f, 60.0f);
	CGRect initialRect3 = CGRectMake(xDelta+-STACK_CASCADE_DELTA, deltay+0.0f, 59.0f, 60.0f);
	
	/* This bit will fix animations */
#if 1
	int r = 0;
	for (MobileStackButton *currentButton in buttonArray)
	{
		
		currentButton.enabled = NO;
		if (r >= 3)
		{
			[currentButton setFrame:initialRect];
			
			
		}
		r++;
	}
#endif
	
	if ([buttonArray count] >= 1)
		[[buttonArray objectAtIndex:0] setFrame:initialRect3];
	
	if ([buttonArray count] >= 2)
		[[buttonArray objectAtIndex:1] setFrame:initialRect2];
	
	if ([buttonArray count] >= 3)
		[[buttonArray objectAtIndex:2] setFrame:initialRect1];
	
#if 0//SHADOW_ENABLED
	for (MobileStackButton *currentButton in buttonArray)
	{
		[[currentButton _shadow] setCenter:currentButton.center];
	}
#endif		
	[toggleStackButton setFrame:initialRect];
	
	
	/* Set end frame for any other icons */
	
	int c = 0;
	for (MobileStackButton *currentButton in buttonArray)
	{
		currentButton.enabled = NO;
		
		if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"cascade"])
		{
			
			
			if (c >= 3)
			{
				//[currentButton setFrame:endRectOther];
				currentButton.alpha = 0.0;
			}
		}
		else if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
		{
			//[currentButton setFrame:endRectOther];
			currentButton.alpha = 0.0;
		}
		else
		{
			if (c >= 1)
			{
				
				
				//[currentButton setFrame:endRectOther];
				currentButton.alpha = 0.0;
			}
		}
		[currentButton hideLabel];
		
		
		c++;
	}
	
	
	if ([[stackPrefs valueForKey:@"DisplayAs"] isEqualToString:@"img"])
	{
		
		[toggleStackButton setImage:[UIImage imageWithContentsOfFile:@"/Library/MobileStack/stack_drawer_button_single.png"] forState:UIControlStateNormal];
	}
	else
		[toggleStackButton setImage:nil forState:UIControlStateNormal];
}


-(CGFloat)stackPosition
{	
	return self.frame.origin.x;
}

id _remove_context_item;

/*- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
 
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
 }*/

-(void)decideRemoveItemFromStack:(id)sender
{	
	[self refreshStackPrefs];
	
	if ([[stackPrefs valueForKey:@"WarnOnRemove"] boolValue] == YES)
	{
		_remove_context_item = sender;
		
		if (!_isShowingAlert)
		{
			UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Remove" message:[NSString stringWithFormat:@"Are you sure you want to remove %@ from Stack?", [sender displayName]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
			[v show];
			[v release];	
			_isShowingAlert = YES;
		}
		
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

#if 0

- (BOOL)allowsCloseBox{
	return NO;
}

- (void)closeBoxClicked:(id)sender
{
	_remove_context_item = self;
	UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Remove this Stack" message:@"Are you sure you want to remove this Stack? It will return on reboot if you have a free Dock space." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
	[v show];
	[v release];
}

#endif

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex

{
	NSLog(@"deesmiss");
	
	
	
	if (buttonIndex == 0)
	{
		//[self removeItemFromStack:_remove_context_item];
	}
	else
	{
		
		if (_remove_context_item == self)
		{
			
			
			id uiC = [NSClassFromString(@"SBUIController") sharedInstance];
			
			UIView *_buttonBarContainerView;
			SBIconList *list;
			
			object_getInstanceVariable(uiC, "_buttonBarContainerView", (void **)&_buttonBarContainerView);
			
			for (UIView *v in [_buttonBarContainerView subviews])
			{
				if ([[v class] isSubclassOfClass:NSClassFromString(@"SBIconList")])
				{
					NSLog(@"SBStackIcon: Found Dock List");
					list = v;
				}
			}
			
			if (!list)
				return;
			
			//[list removeIcon:self compactEmptyLists:YES animate:YES];
			
			[self setIsHidden:YES animate:YES];
			[list removeIcon:self compactEmptyLists:YES animate:YES];
			[list layoutIconsNow];
			
			
		}
		else 
			
			[self removeItemFromStack:_remove_context_item];
	}
	
	_isShowingAlert = NO;
	
	_remove_context_item = nil;
}

/*
 - (BOOL)pointInside:(struct CGPoint)fp8 withEvent:(id)fp16
 {
 NSLog(@"POint insider = %@", NSStringFromCGPoint(fp8));
 
 if ([self isShowingCloseBox])
 return NO;
 
 
 return YES;
 }*/

/*
 - (BOOL)launchEnabled
 {
 return NO;
 }*/

- (void)setIsJittering:(BOOL)fp8
{
	[self closeStack:self];
	[super setIsJittering:fp8];
}

#pragma mark -

@end
