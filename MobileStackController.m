#import "MobileStackController.h"

BOOL curveIsEnabled = YES;
BOOL forceGridView = NO;

@implementation UIView (Color)

+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
{
    float rgba[4] = {red, green, blue, alpha};
    CGColorSpaceRef rgbColorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
    CGColorRef color = (CGColorRef)[(id)CGColorCreate(rgbColorSpace, rgba) autorelease];
    return color;
}

@end

@implementation MobileStackController

/* Code lifted from http://www.cocoabuilder.com/archive/message/cocoa/2002/2/7/59315 */

-(void)killStackProcess
{
int mib[ 3 ] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
    size_t length;
    struct kinfo_proc *theProcessInfoData;
    struct kinfo_proc *theProcessInfo;
    NSString *theProcessName;
    pid_t theProcessID;

    if( sysctl( mib, 3, NULL, &length, NULL, 0 ) == -1 ) return;

    theProcessInfoData = (struct kinfo_proc*)malloc( length );

    if( sysctl( mib, 3, theProcessInfoData, &length, NULL, 0 ) != -1 ) {
        theProcessInfo = theProcessInfoData;

        do {
            theProcessName = [NSString stringWithCString:theProcessInfo -> kp_proc.p_comm];
            theProcessID = theProcessInfo -> kp_proc.p_pid;
			
			if ([theProcessName isEqualToString:@"stack_binary"])
			{
			NSLog(@"Stack process id is: %d", (int)theProcessID);
			
			NSLog(@"Killing Stack Process");
			
			kill((int)theProcessID, SIGTERM);
			
				UIAlertSheet *_infoSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
				[_infoSheet setBodyText:@"Stack has been terminated. It should relaunch automatically."];
				[_infoSheet setRunsModal:YES];
				[_infoSheet setTitle:@"Stack Relaunched"];
				[_infoSheet popupAlertAnimated:YES];
			}
			
            theProcessInfo ++;
        } while( (size_t)theProcessInfo < (size_t)theProcessInfoData + length );
    }

    free( (void*)theProcessInfoData );
	
}

- (void) applicationDidFinishLaunching: (id) unused
{

	if ([self platform] == kUnsupported)
	{
	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Stack is only supported on System Software 1.0.2 and 1.1.1. Please upgrade your System Software."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Unsupported OS"];
	[_errorSheet setBlocksInteraction:YES];
	[_errorSheet popupAlertAnimated:YES];
	[_errorSheet setDelegate:self];
	while ([UIAlertSheet topMostAlert] == _errorSheet){}
	[self terminate];
	}


	NSLog(@"Launch");
	
	NSMutableDictionary *stackPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack" stringByExpandingTildeInPath]];

	if (!stackPrefs)
	stackPrefs = [NSMutableDictionary dictionary];

	if ([[stackPrefs valueForKey:@"UseCurvedStack"] boolValue] == YES)
	{
	
	NSLog(@"Curved is enabled");
	curveIsEnabled = YES;
	}
	else
	{
	NSLog(@"Curved is disabled");
	curveIsEnabled = NO;
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

	CGRect rect = [UIHardware fullScreenApplicationContentRect];

	window = [[UIWindow alloc] initWithContentRect:rect];
	contentView = [[UIView alloc] initWithFrame: [window bounds]];
	
	UIPreferencesTable *preferencesTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 45.0f, [window bounds].size.width, [window bounds].size.height-45.0f)];

	CGRect switchRect = CGRectMake(rect.size.width - 114.0f, 9.0f, 96.0f, 32.0f);
	CGRect installButtonRect = CGRectMake(20.0f, 9.0f, [window bounds].size.width-40, 46.0f);

	[preferencesTable setDataSource: self];
	[preferencesTable setDelegate: self];
	
	optionsGroup = [[UIPreferencesTableCell alloc] init];
	[optionsGroup setTitle:@"Stack Options"];


	geometryCell = [[UIPreferencesTableCell alloc] init];
	[geometryCell setTitle: @"Use Curved Stack"];
	geometrySwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[geometrySwitch setValue: curveIsEnabled];
	[geometryCell addSubview: geometrySwitch];
	
	forceGridViewCell = [[UIPreferencesTableCell alloc] init];
	[forceGridViewCell setTitle: @"Always Use Grid View"];
	forceGridViewSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[forceGridViewSwitch setValue: forceGridView];
	[forceGridViewCell addSubview: forceGridViewSwitch];
	
	entriesCell = [[UIPreferencesTableCell alloc] init];
	[entriesCell setTitle: @"Edit Stack Contents"];

	installGroup = [[UIPreferencesTableCell alloc] init];
	
	[installGroup setTitle:@"Stack Installation"];
	installCell = [[UIPreferencesTableCell alloc] init];
	removeCell = [[UIPreferencesTableCell alloc] init];
	
	terminateGroup = [[UIPreferencesTableCell alloc] init];
	[terminateGroup setTitle:@"Advanced"];
	terminateCell = [[UIPreferencesTableCell alloc] init];


	CGRect left = CGRectMake(0.0f, 0.0f, 14.0f, 46.0f);	
	CGRect middle = CGRectMake(14.0f, 0.0f, 1.0f, 46.0f);
	CGRect right = CGRectMake(15.0f, 0.0f, 14.0f, 46.0f);
	CDAnonymousStruct4 slices = { left, middle, right };

	installButton = [[UIThreePartButton alloc] initWithTitle:@"Install Stack"];
	[installButton setEnabled:YES];
	[installButton setAutosizesToFit:NO];
	[installButton setFrame:installButtonRect];
	[installButton setBackgroundSlices:slices];
	[installButton setBackgroundImage:[UIImage applicationImageNamed:@"UIButtonLarge.png"] ];
	[installButton setTitleColor:[UIView colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] forState:0];
	[installButton addTarget:self action:@selector(installStack:) forEvents:1];
	
	removeButton = [[UIThreePartButton alloc] initWithTitle:@"Remove Stack"];
	[removeButton setEnabled:YES];
	[removeButton setAutosizesToFit:NO];
	[removeButton setFrame:installButtonRect];
	[removeButton setBackgroundSlices:slices];
	[removeButton setBackgroundImage:[UIImage applicationImageNamed:@"UIDeleteButtonLarge.png"] ];
	[removeButton addTarget:self action:@selector(uninstallStack:) forEvents:1];
	
	terminateButton = [[UIThreePartButton alloc] initWithTitle:@"Relaunch Stack"];
	[terminateButton setEnabled:YES];
	[terminateButton setAutosizesToFit:NO];
	[terminateButton setFrame:installButtonRect];
	[terminateButton setBackgroundSlices:slices];
	[terminateButton setBackgroundImage:[UIImage applicationImageNamed:@"UIButtonLarge.png"] ];
	[terminateButton setTitleColor:[UIView colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] forState:0];
	[terminateButton addTarget:self action:@selector(killStackProcess) forEvents:1];

	[installCell addSubview: installButton];
	[removeCell addSubview: removeButton];

	[terminateCell addSubview: terminateButton];

	UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, [window bounds].size.width, 45.0f)];
	[navigationBar setDelegate: self];
	
	UINavigationItem *titleNavItem = [[UINavigationItem alloc] initWithTitle: @"Stack Settings"];
	[navigationBar pushNavigationItem: titleNavItem];	

	[navigationBar setDelegate: self];
	
	[contentView addSubview: navigationBar];
	[contentView addSubview:preferencesTable];
						
	[window setContentView:contentView];
	[window orderFront: self];
	[window makeKey: self];
	
	[preferencesTable reloadData];

}

-(int)platform
{


NSDictionary *systemVersion = [[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];

NSString *productBuildVersion = [systemVersion valueForKey:@"ProductBuildVersion"];

if ([productBuildVersion hasPrefix:@"1"])
return kiPhone1_0_2;
else
{
 if ([[UIHardware deviceName] isEqualToString:@"iPod"])
 {
	return kiPodTouch;
 }
 else
 {
	return kiPhone;
}

}
/*
if ([productBuildVersion isEqualToString:@"3A110a"])
return kiPodTouch;
else if ([productBuildVersion isEqualToString:@"3A109a"])
return kiPhone1_1_1;
else if ([productBuildVersion isEqualToString:@"1C28"])
return kiPhone1_0_2;
else if ([productBuildVersion isEqualToString:@"3B48b"])
return kUnknown1_1_2;
else

return kUnsupported;
*/
}

-(void)uninstallStack:(id)sender
{
NSMutableDictionary *springBoardConfiguration;

if ([self platform] == kiPodTouch)
springBoardConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/N45AP.plist"];
else if ([self platform] == kiPhone)
springBoardConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/M68AP.plist"];
else if ([self platform] == kiPhone1_0_2)
springBoardConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/DisplayOrder.plist"];

NSMutableArray *buttonBarConfiguration = [[springBoardConfiguration valueForKey:@"displayOrder"] valueForKey:@"buttonBar"];

NSDictionary *previousConfigItem = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.previousbuttonbar" stringByExpandingTildeInPath]];

if (![previousConfigItem count] > 0)
{
	
	if ([self platform] == kiPodTouch)
	previousConfigItem = [NSDictionary dictionaryWithObject:@"com.apple.MobileStore" forKey:@"displayIdentifier"];
	else
	previousConfigItem = [NSDictionary dictionaryWithObject:@"com.apple.mobileipod-MediaPlayer" forKey:@"displayIdentifier"];

}

[buttonBarConfiguration replaceObjectAtIndex:3 withObject:previousConfigItem];

[[springBoardConfiguration valueForKey:@"displayOrder"] setValue:buttonBarConfiguration forKey:@"buttonBar"];

BOOL barSuccess;

if ([self platform] == kiPodTouch)
barSuccess = [springBoardConfiguration writeToFile:@"/System/Library/CoreServices/SpringBoard.app/N45AP.plist" atomically:NO];
else if ([self platform] == kiPhone)
barSuccess = [springBoardConfiguration writeToFile:@"/System/Library/CoreServices/SpringBoard.app/M68AP.plist" atomically:NO];
else if ([self platform] == kiPhone1_0_2)
barSuccess = [springBoardConfiguration writeToFile:@"/System/Library/CoreServices/SpringBoard.app/DisplayOrder.plist" atomically:NO];

if (!barSuccess)
{

	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Unable to write SpringBoard configuration."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Error"];
	[_errorSheet popupAlertAnimated:YES];

	return;
}

// Remove Stack.app from /Applications

[[NSFileManager defaultManager] removeFileAtPath:@"/Applications/Stack.app" handler:nil];

// Remove LaunchDaemon

if ([[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/LaunchDaemons/com.steventroughtonsmith.stack"])
{

// Gotta clean this up, earlier builds placed the file in the wrong place.

[[NSFileManager defaultManager] removeFileAtPath:@"/System/Library/LaunchDaemons/com.steventroughtonsmith.stack" handler:nil];


}

BOOL daemonSuccess = [[NSFileManager defaultManager] removeFileAtPath:@"/Library/LaunchDaemons/com.steventroughtonsmith.stack" handler:nil];

if (!daemonSuccess)
{

	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Unable to disable Stack auto-launch."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Error"];
	[_errorSheet popupAlertAnimated:YES];


	return;
}

// Prompt user to reboot

	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Stack was successfully uninstalled. Please reboot your device."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Success"];
	[_errorSheet popupAlertAnimated:YES];

}


-(void)installStack:(id)sender
{

NSLog(@"Installing");

// Copy Stack.app to /Applications

[[NSFileManager defaultManager] createSymbolicLinkAtPath:@"/Applications/Stack.app" pathContent:@"/Applications/StackController.app/Stack.app"];


// Add Stack to Springboard Button Bar

NSMutableDictionary *springBoardConfiguration;

if ([self platform] == kiPodTouch)
springBoardConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/N45AP.plist"];
else if ([self platform] == kiPhone)
springBoardConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/M68AP.plist"];
else if ([self platform] == kiPhone1_0_2)
springBoardConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/DisplayOrder.plist"];


NSMutableArray *buttonBarConfiguration = [[springBoardConfiguration valueForKey:@"displayOrder"] valueForKey:@"buttonBar"];

if (![[[buttonBarConfiguration objectAtIndex:3] valueForKey:@"displayIdentifier"] isEqualToString:@"com.steventroughtonsmith.stack"])
[[buttonBarConfiguration objectAtIndex:3] writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack.previousbuttonbar" stringByExpandingTildeInPath] atomically:NO];

[buttonBarConfiguration replaceObjectAtIndex:3 withObject:[NSDictionary dictionaryWithObject:@"com.steventroughtonsmith.stack" forKey:@"displayIdentifier"]];

[[springBoardConfiguration valueForKey:@"displayOrder"] setValue:buttonBarConfiguration forKey:@"buttonBar"];

BOOL barSuccess;

if ([self platform] == kiPodTouch)
barSuccess =[springBoardConfiguration writeToFile:@"/System/Library/CoreServices/SpringBoard.app/N45AP.plist" atomically:NO];
else if ([self platform] == kiPhone)
barSuccess =[springBoardConfiguration writeToFile:@"/System/Library/CoreServices/SpringBoard.app/M68AP.plist" atomically:NO];
else if ([self platform] == kiPhone1_0_2)
barSuccess = [springBoardConfiguration writeToFile:@"/System/Library/CoreServices/SpringBoard.app/DisplayOrder.plist" atomically:NO];

if (!barSuccess)
{

	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Unable to write SpringBoard configuration."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Error"];
	[_errorSheet popupAlertAnimated:YES];

	return;
}

// Copy com.steventroughtonsmith.stack to LaunchDaemons

NSString *daemonContents = [NSString stringWithContentsOfFile:@"/Applications/StackController.app/com.steventroughtonsmith.stack" encoding:NSMacOSRomanStringEncoding error:nil];

if ([[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/LaunchDaemons/com.steventroughtonsmith.stack"])
{

// Gotta clean this up, earlier builds placed the file in the wrong place.

// Dear god, there's no movePath: toPath: in iPhone's NSFileManager. What an omission! Dirty hack follows.

NSString *temp = [NSString stringWithContentsOfFile:@"/System/Library/LaunchDaemons/com.steventroughtonsmith.stack" encoding:NSMacOSRomanStringEncoding error:nil];
[temp writeToFile:@"/Library/LaunchDaemons/com.steventroughtonsmith.stack" atomically:NO encoding:NSMacOSRomanStringEncoding error:nil];

[[NSFileManager defaultManager] removeFileAtPath:@"/System/Library/LaunchDaemons/com.steventroughtonsmith.stack" handler:nil];

}


BOOL daemonSuccess = [daemonContents writeToFile:@"/Library/LaunchDaemons/com.steventroughtonsmith.stack" atomically:NO encoding:NSMacOSRomanStringEncoding error:nil];

if (!daemonSuccess)
{

	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Unable to enable Stack auto-launch."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Error"];
	[_errorSheet popupAlertAnimated:YES];


	return;
}

// Prompt user to reboot

	UIAlertSheet *_errorSheet = [[UIAlertSheet alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect]];
	[_errorSheet setBodyText:@"Stack was installed. Please reboot your device."];
	[_errorSheet setRunsModal:YES];
	[_errorSheet setTitle:@"Success"];
	[_errorSheet popupAlertAnimated:YES];


}

- (void)applicationSuspend:(struct __GSEvent *)event  {



	curveIsEnabled = [geometrySwitch value];
	forceGridView = [forceGridViewSwitch value];

	NSMutableDictionary *stackPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack" stringByExpandingTildeInPath]];
	
	if (!stackPrefs)
	stackPrefs = [NSMutableDictionary dictionary];

	[stackPrefs setValue:[NSNumber numberWithBool:curveIsEnabled] forKey:@"UseCurvedStack"];
	[stackPrefs setValue:[NSNumber numberWithBool:forceGridView] forKey:@"ForceGridView"];
	
	BOOL success = [stackPrefs writeToFile:[@"~/Library/Preferences/com.steventroughtonsmith.stack" stringByExpandingTildeInPath] atomically:NO];

}

-(void)editStackContents
{


}

#pragma mark -

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable *)table {
	return 7;
}

- (int) preferencesTable: (UIPreferencesTable *)table numberOfRowsInGroup: (int) group {
	switch(group) {
		case 0: return 0;
		case 1: return 3;
		case 2: return 0;
		case 3: return 2;
		case 4: return 0;
		case 5: return 1;
		default: return 0;
	}
}

- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForGroup: (int)group {
	switch(group) {
		case 0: return optionsGroup;
		case 2: return installGroup;
		case 4: return terminateGroup;

		default: return nil;
	}
}

- (float)preferencesTable: (UIPreferencesTable *)table heightForRow: (int)row inGroup:(int)group withProposedHeight: (float)proposed {
	switch(group) {
		case 0: return 26.0f;
		case 2: return 26.0f;
		case 3:
			switch (row)
			{
			case 0 : return (46.0f+18.0f);
			case 1 : return (46.0f+18.0f);
			}
		case 5:
			switch (row)
			{
			case 0 : return (46.0f+18.0f);
			}
		default: return proposed;
	}
}

/*
- (BOOL)preferencesTable: (UIPreferencesTable *)table isLabelGroup: (int)group {
	switch(group) {
		case 0: return TRUE;
		default: return FALSE;
	}
}*/

- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForRow: (int)row inGroup: (int)group {
	switch(group) {
		case 0: return optionsGroup;
		case 1:
			switch(row) {
				case 0: return geometryCell;
				case 1: return forceGridViewCell;
				case 2: return entriesCell;
				
		}
		case 2: return installGroup;
		case 3:
			switch(row) {
				case 0: return installCell;
				case 1: return removeCell;
			}
		case 4: return terminateGroup;
		case 5:
		switch(row) {
				case 0: return terminateCell;
			}

		default: return nil;
	}
}

@end
